#!/usr/bin/env bash
# dispatch-ledger.sh（max-subagents ledger.py 薄壳）自测
# 在临时 git 仓库 + 独立临时 ROOT 上跑，绝不触碰真实 dmt 仓库的 locks 目录。
# 用法：bash scripts/test-dispatch-ledger.sh
set -u

REAL_SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
KERNEL="/home/panxiaoyong/pxy/projects26h2/max-subagents/ledger.py"

FAIL=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAIL=1; }
assert_eq() { [ "$1" = "$2" ] && pass "$3" || fail "$3 (got='$1' want='$2')"; }
expect_rc() { [ "$1" = "$2" ] && pass "$3 (rc=$1)" || fail "$3 (rc=$1 want=$2)"; }

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

# --- 假 git 仓库：让 dmt_root 指到临时 ROOT（tests 绝不碰真实仓库）---
REPO="$TMP/repo"
mkdir -p "$REPO"
cp -r "$REAL_SCRIPTS" "$REPO/scripts"
cd "$REPO"
git init -q
echo test > README.md
git add -A
git -c user.email=t@t -c user.name=t commit -q -m init

ROLE="uD2test"
DL="$REPO/scripts/dispatch-ledger.sh"
export DMT_DISPATCH_ALL=1
unset DMT_ROLE HERDR_PANE_ID 2>/dev/null || true
ROOT="$REPO"
LEDGER="$ROOT/locks/dispatch-$ROLE.tsv"
LOCKDIR="$ROOT/locks/.dispatch-$ROLE.tsv.lock"

echo "临时 ROOT = $ROOT"
echo "临时账本  = $LEDGER"
echo

# 直接问内核取数（测试断言用；dmt 壳没有 query 子命令）
kq() { python3 "$KERNEL" query --ledger-path "$LEDGER" --session "$ROLE" --json 2>/dev/null; }

echo "===== ① plan 后 status 与 report 反映单元数 ====="
out="$(bash "$DL" plan "$ROLE" u1 u2 u3 2>&1)"; rc=$?
echo "$out"; echo "[plan rc=$rc]"; expect_rc 0 "$rc" "plan u1 u2 u3"
out="$(bash "$DL" status "$ROLE" 2>&1)"; rc=$?
echo "$out"; echo "[status rc=$rc]"; expect_rc 0 "$rc" "status rc=0"
printf '%s\n' "$out" | grep -q 'u3' && pass "status 含 u3" || fail "status 缺 u3"
out="$(bash "$DL" report "$ROLE" 2>&1)"; rc=$?
echo "$out"; echo "[report rc=$rc]"; expect_rc 0 "$rc" "report rc=0"
printf '%s\n' "$out" | grep -q '单元 3' && pass "report 反映单元 3" || fail "report 未反映单元 3"
echo

echo "===== ② inc 自动认领第一个 planned ====="
out="$(printf '{}' | bash "$DL" inc "$ROLE" 2>&1)"; rc=$?
echo "$out"; echo "[inc rc=$rc]"; expect_rc 0 "$rc" "inc 自动认领 rc=0"
q="$(kq)"; echo "kernel query = $q"
assert_eq "$(awk -F'\t' '$1=="u1"{print $2}' "$LEDGER")" "dispatched" "u1 被认领为 dispatched"
assert_eq "$(printf '%s' "$q" | jq -r '.pending')" "2" "剩余 pending=2"
assert_eq "$(printf '%s' "$q" | jq -r '.inflight')" "1" "inflight=1"
echo

echo "===== ③ plan 重复单元被拒 rc=2 且不写账 ====="
bash "$DL" plan "$ROLE" a b >/dev/null 2>&1
before="$(cat "$LEDGER")"
out="$(bash "$DL" plan "$ROLE" x y x 2>&1)"; rc=$?
echo "$out"; echo "[plan dup rc=$rc]"; expect_rc 2 "$rc" "重复单元 rc=2"
assert_eq "$(cat "$LEDGER")" "$before" "被拒 plan 未改动账本"
echo

echo "===== ④ 假 pid 残留锁被接管（<3s, rc=0）====="
mkdir -p "$LOCKDIR"
echo 999999 > "$LOCKDIR/pid"
date +%s > "$LOCKDIR/ts"
t0=$(date +%s%N)
out="$(bash "$DL" plan "$ROLE" L1 2>&1)"; rc=$?
t1=$(date +%s%N)
ms=$(( (t1 - t0) / 1000000 ))
echo "$out"; echo "[plan rc=$rc, elapsed=${ms}ms]"
expect_rc 0 "$rc" "残留锁接管后 plan rc=0"
[ "$ms" -lt 3000 ] && pass "接管耗时 ${ms}ms < 3000ms" || fail "接管耗时 ${ms}ms >= 3000ms"
[ -d "$LOCKDIR" ] && fail "锁目录未清理" || pass "锁目录已清理"
echo

echo "===== ⑤ 带 agent_id 的 payload 不被销账 ====="
bash "$DL" plan "$ROLE" s1 >/dev/null 2>&1
out="$(printf '%s' '{"tool_name":"Agent","agent_id":"agent-9"}' | bash "$DL" inc "$ROLE" 2>&1)"; rc=$?
echo "$out"; echo "[inc subagent rc=$rc]"; expect_rc 0 "$rc" "subagent inc rc=0"
assert_eq "$(awk -F'\t' '$1=="s1"{print $2}' "$LEDGER")" "planned" "s1 仍为 planned（未被销账）"
echo

echo "===== ⑥ check 有未派且在途 0 → rc=2 ====="
out="$(printf '{}' | bash "$DL" check "$ROLE" 2>&1)"; rc=$?
echo "$out"; echo "[check rc=$rc]"; expect_rc 2 "$rc" "check rc=2 阻断收工"
echo

echo "===== ⑦ check stop_hook_active=true → rc=0 ====="
out="$(printf '%s' '{"stop_hook_active":true}' | bash "$DL" check "$ROLE" 2>&1)"; rc=$?
echo "$out"; echo "[check rc=$rc]"; expect_rc 0 "$rc" "stop_hook_active rc=0"
echo

echo "===== ⑧ ledger-path 输出与老布局一致 ====="
out="$(bash "$DL" ledger-path "$ROLE" 2>&1)"; rc=$?
echo "$out"; echo "[ledger-path rc=$rc]"
assert_eq "$out" "$LEDGER" 'ledger-path == $ROOT/locks/dispatch-<role>.tsv'
echo

echo "===== ⑨ (附加) 旧账本（HHMMSS 时间列）仍可读 ====="
printf 'old1\tplanned\t-\t141159\nold2\tdone\t-\t141200\n' > "$LEDGER"
out="$(bash "$DL" status "$ROLE" 2>&1)"; rc=$?
echo "$out"; echo "[status old-fmt rc=$rc]"; expect_rc 0 "$rc" "旧账本 status rc=0"
printf '%s\n' "$out" | grep -q 'old1' && pass "旧账本 old1 可读" || fail "旧账本 old1 丢失"
out="$(bash "$DL" report "$ROLE" 2>&1)"; echo "$out"
printf '%s\n' "$out" | grep -q '单元 2' && pass "旧账本 report 单元 2" || fail "旧账本 report 计数错"
out="$(printf '{}' | bash "$DL" check "$ROLE" 2>&1)"; rc=$?
echo "$out"; echo "[check old-fmt rc=$rc]"
expect_rc 2 "$rc" "旧账本 planned 仍阻断（与旧行为一致）"
echo

echo "===== ⑩ (附加) 非治理角色静默 exit 0 ====="
out="$(env -u DMT_DISPATCH_ALL bash "$DL" status "nobody" 2>&1)"; rc=$?
echo "output='${out}' rc=$rc"
expect_rc 0 "$rc" "非治理角色 status rc=0"
[ -z "$out" ] && pass "非治理角色静默（无输出）" || fail "非治理角色有输出: $out"
out="$(env -u DMT_DISPATCH_ALL bash "$DL" check "nobody" </dev/null 2>&1)"; rc=$?
echo "check output='${out}' rc=$rc"
expect_rc 0 "$rc" "非治理角色 check rc=0"
echo

echo "===== ⑪ append 追加过账（一子代理一单元队列，2026-10-27 事故 P3） ====="
rm -f "$LEDGER"
bash "$DL" plan "$ROLE" u1 >/dev/null 2>&1
printf '%s' '{"tool_name":"Agent","agent_id":"a1"}' | bash "$DL" inc "$ROLE" >/dev/null 2>&1
out="$(bash "$DL" append "$ROLE" 2>&1)"; rc=$?
expect_rc 2 "$rc" "append 无单元 rc=2"
out="$(bash "$DL" append "$ROLE" u2 u3 2>&1)"; rc=$?
echo "$out"; echo "[append rc=$rc]"; expect_rc 0 "$rc" "append rc=0"
printf '%s\n' "$out" | grep -q 'u2' && pass "append u2 过账" || fail "append u2 未过账"
printf '%s\n' "$out" | grep -q 'u3' && pass "append u3 过账" || fail "append u3 未过账"
out="$(bash "$DL" report "$ROLE" 2>&1)"; echo "$out"
printf '%s\n' "$out" | grep -q '单元 3' && pass "append 后单元 3" || fail "append 后计数错"
printf '%s\n' "$out" | grep -q '派 3' && pass "append 后派 3（含追加 2）" || fail "append 后派数错"
grep -q $'^u1\tdispatched' "$LEDGER" && pass "append 不动既有行（u1 仍 dispatched）" || fail "append 动了既有行"
echo

echo "===== 结果 ====="
if [ "$FAIL" = 0 ]; then echo "ALL PASS"; else echo "SOME FAILED"; fi
exit "$FAIL"
