import os
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
CHECK = REPO / "dmt-dir/scripts/check-dmt.sh"
INSTALL = REPO / "dmt-dir/scripts/install-skills.sh"
SEND = REPO / "dmt-dir/scripts/send-msg.sh"


def run(*args, cwd=REPO, env=None):
    merged = os.environ.copy()
    if env:
        merged.update(env)
    return subprocess.run(
        [str(a) for a in args],
        cwd=cwd,
        env=merged,
        text=True,
        capture_output=True,
        timeout=120,
    )


class DmtRegressionTests(unittest.TestCase):
    def assert_pass(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stdout.strip().splitlines()[-1], "ALL_PASS")

    def install(self, target, copy=False):
        args = ["bash", INSTALL, target, "--harness", "codebuddy"]
        if copy:
            args.append("--copy")
        result = run(*args)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("ALL_PASS", result.stdout.splitlines())
        return target / ".codebuddy/skills"

    def installed_check(self, target, skills):
        return run(
            "bash",
            target / "dmt-dir/scripts/check-dmt.sh",
            target,
            env={"DMT_SKILLS_DIR": str(skills)},
        )

    def test_repository_check_is_quiet(self):
        result = run("bash", CHECK, REPO, env={"DMT_SKILLS_DIR": str(REPO)})
        self.assert_pass(result)
        self.assertEqual(result.stdout.strip(), "ALL_PASS")
        self.assertEqual(result.stderr, "")

    def test_verbose_check_shows_ok_details(self):
        result = run(
            "bash", CHECK, "--verbose", REPO, env={"DMT_SKILLS_DIR": str(REPO)}
        )
        self.assert_pass(result)
        self.assertIn("OK ", result.stdout)
        self.assertGreater(len(result.stdout.splitlines()), 10)

    def test_skill_entries_are_small_and_have_no_forced_startup(self):
        entries = sorted(REPO.glob("dmt-*/SKILL.md"))
        self.assertEqual(len(entries), 7)
        self.assertLessEqual(sum(len(p.read_text().splitlines()) for p in entries), 220)
        self.assertLessEqual(len((REPO / "dmt-dir/SKILL.md").read_text().splitlines()), 25)
        for path in entries:
            text = path.read_text()
            self.assertNotIn("每次加载先做", text)
            self.assertNotIn("harness-detect.sh", text)
            self.assertNotRegex(text, r"bash\s+\S*init-project\.sh")

    def test_link_install_needs_no_fixed_project_directories(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "generic-project"
            skills = self.install(target)
            self.assertFalse((target / "docs/pd").exists())
            self.assertFalse((target / "inbox").exists())
            self.assertFalse((target / "dmt-dir/CHANGELOG.md").exists())
            self.assertFalse((skills / "dmt-dir/CHANGELOG.md").exists())
            result = self.installed_check(target, skills)
            self.assert_pass(result)
            self.assertEqual(result.stdout.strip(), "ALL_PASS")

    def test_copy_install_is_self_contained(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "copy-project"
            skills = self.install(target, copy=True)
            self.assertFalse((target / "dmt-dir/CHANGELOG.md").exists())
            result = self.installed_check(target, skills)
            self.assert_pass(result)
            self.assertEqual(result.stdout.strip(), "ALL_PASS")

    def test_broken_relative_link_fails_from_source_directory(self):
        with tempfile.TemporaryDirectory() as tmp:
            target = Path(tmp) / "broken-link-project"
            skills = self.install(target)
            (target / "docs").mkdir()
            (target / "docs/broken.md").write_text(
                "[missing](../definitely-not-present.md)\n", encoding="utf-8"
            )
            result = self.installed_check(target, skills)
            self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
            self.assertIn("断链", result.stderr)
            self.assertIn("definitely-not-present.md", result.stderr)
            self.assertEqual(result.stdout.strip(), "HAS_FAIL")

    def test_message_sequence_padding_and_growth(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            body = root / "body.md"
            body.write_text("test\n", encoding="utf-8")
            box = root / "inbox/dmt-dir"
            box.mkdir(parents=True)
            for current, expected in ((9, "010"), (99, "100"), (999, "1000")):
                with self.subTest(current=current):
                    (box / ".seq").write_text(f"{current}\n", encoding="utf-8")
                    result = run(
                        "bash",
                        SEND,
                        "dmt-dir",
                        "dmt-dir-helper",
                        "sequence-test",
                        body,
                        cwd=root,
                        env={"DMT_HERDR_SOCKET_PATH": str(root / "no-herdr.sock")},
                    )
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertTrue(result.stdout.strip().startswith(expected + "-"))
                    self.assertEqual((box / ".seq").read_text().strip(), str(int(expected)))


if __name__ == "__main__":
    unittest.main()
