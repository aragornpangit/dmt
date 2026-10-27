#!/usr/bin/env bash
# 把 dmt 技能装到目标项目（默认软链，--copy 则复制）
# 用法：bash install-skills.sh <project-root> [--copy]
# 落点：技能 -> <target>/.agents/skills/<角色>/；契约 -> <target>/docs/team.md；
#       脚本与契约原样 -> <target>/dmt-director/（team.md 里的命令一律写 dmt-director/scripts/…）
set -eu
TARGET="${1:?usage: install-skills.sh <project-root> [--copy]}"
MODE="${2:-link}"
case "$MODE" in
  link) ;;
  --copy|copy) MODE=copy ;;
  *) echo "unknown arg: $2（只认 --copy）" >&2; exit 2 ;;
esac
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
TARGET="$(cd "$TARGET" && pwd)"
SKILLS="dmt-director dmt-pde dmt-dm dmt-am"

mkdir -p "$TARGET/.agents/skills"
for s in $SKILLS; do
  if [ "$MODE" = "--copy" ]; then
    rm -rf "$TARGET/.agents/skills/$s"
    cp -r "$REPO/$s" "$TARGET/.agents/skills/$s"
  else
    # 目标已存在且是实体目录（旧版复制的技能）时必须先删，否则 ln -sfn 会把软链建到目录里面
    rm -rf "$TARGET/.agents/skills/$s"
    ln -sfn "$REPO/$s" "$TARGET/.agents/skills/$s"
  fi
done

# 脚本目录固定为 <target>/dmt-director/scripts/ —— 与契约里所有命令写法一致。
# 旧版曾复制到 <target>/scripts/，从项目根执行 $TARGET/scripts/… 会 rc=127（已废弃）。
if [ "$MODE" = "--copy" ]; then
  rm -rf "$TARGET/dmt-director"
  cp -r "$REPO/dmt-director" "$TARGET/dmt-director"
elif [ -e "$TARGET/dmt-director" ] && [ ! -L "$TARGET/dmt-director" ]; then
  echo "WARN: $TARGET/dmt-director 已存在且不是软链，沿用现有目录" >&2
else
  ln -sfn "$REPO/dmt-director" "$TARGET/dmt-director"
fi
chmod +x "$TARGET/dmt-director/scripts/"*.sh 2>/dev/null || true

mkdir -p "$TARGET/docs"
cp "$REPO/dmt-director/team.md" "$TARGET/docs/team.md"

bash "$TARGET/dmt-director/scripts/init-project.sh" "$TARGET"
echo "installed ($MODE) into $TARGET"
