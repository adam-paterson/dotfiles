"""Run with python3 tests/test_skills.py; no downloads or real installs."""

import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SYNC = ROOT / "src/dot_local/bin/executable_skills-sync"
LOCK = ROOT / "src/dot_agents/skills-lock.json"
SYMLINK = ROOT / "src/symlink_skills-lock.json"

# The committed lock must be fully pinned: every entry carries the git commit
# and content hash the CLI v3 schema records, so frozen installs are exact.
lock = json.loads(LOCK.read_text())
assert isinstance(lock, dict) and isinstance(lock.get("skills"), dict), "lock shape"
unpinned = sorted(
    name for name, entry in lock["skills"].items()
    if not entry.get("commit") or not entry.get("computedHash")
)
assert not unpinned, f"unpinned entries: {unpinned}"
assert SYMLINK.read_text() == ".agents/skills-lock.json", "home lock symlink"

with tempfile.TemporaryDirectory() as directory:
    home = Path(directory).resolve()

    # Fake npx: records the CLI invocation and restores every locked skill.
    local_bin = home / ".local/bin"
    local_bin.mkdir(parents=True)
    npx = local_bin / "npx"
    npx.write_text(
        '#!/usr/bin/env python3\n'
        'import json, os, pathlib, sys\n'
        'home = pathlib.Path.home()\n'
        '(home / "call").write_text(json.dumps(sys.argv[1:]))\n'
        'cwd = pathlib.Path.cwd()\n'
        '(cwd / "npx-cwd").write_text(str(cwd))\n'
        'if os.environ.get("SKILLS_EXIT"): sys.exit(int(os.environ["SKILLS_EXIT"]))\n'
        'lock_path = cwd / "skills-lock.json"\n'
        'lock = json.loads(lock_path.read_text())\n'
        'if os.environ.get("SKILLS_REWRITE_LOCK"):\n'
        '    lock_path.write_text(json.dumps(lock))\n'
        'for name, entry in lock["skills"].items():\n'
        '    if name == os.environ.get("SKILLS_OMIT"): continue\n'
        '    p = cwd / ".agents/skills" / name\n'
        '    p.mkdir(parents=True, exist_ok=True)\n'
        '    (p / "SKILL.md").write_text("upstream skill\\n")\n'
    )
    npx.chmod(0o755)

    # Fake chezmoi: reports the vendored skill as managed so pruning skips it.
    chezmoi = local_bin / "chezmoi"
    chezmoi.write_text('#!/bin/sh\necho "$HOME/.agents/skills/vendored-skill"\n')
    chezmoi.chmod(0o755)

    env = {**os.environ, "HOME": str(home)}
    (home / ".agents").mkdir()
    shutil.copy(LOCK, home / ".agents/skills-lock.json")
    (home / "skills-lock.json").symlink_to(".agents/skills-lock.json")
    # Fixture entries the fake CLI installs; the real lock stays untouched.
    home_lock = home / ".agents/skills-lock.json"
    data = json.loads(home_lock.read_text())
    data["skills"]["upstream-skill"] = {
        "source": "fixture/repo", "sourceType": "github",
        "commit": "a" * 40, "computedHash": "h" * 64,
    }
    home_lock.write_text(json.dumps(data))

    # The reconciler runs the frozen install in ~/.agents.
    result = subprocess.run([str(SYNC)], env=env, capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    assert json.loads((home / "call").read_text()) == [
        "--yes", "skills@1.9.0", "install", "--frozen-lockfile"
    ], json.loads((home / "call").read_text())
    assert (home / "npx-cwd").read_text() == str(home)

    # Restore writes into ~/.agents/skills.
    restored = home / ".agents/skills/upstream-skill"
    assert (restored / "SKILL.md").read_text() == "upstream skill\n"

    # Prune stays a dry run until the marker file arms deletion.
    assert not (home / ".agents/skills/stray-skill").exists()
    (home / ".agents/skills/stray-skill").mkdir()
    (home / ".agents/skills/stray-skill/SKILL.md").write_text("stray\n")
    (home / ".agents/skills/vendored-skill").mkdir()
    (home / ".agents/skills/vendored-skill/SKILL.md").write_text("vendored\n")
    result = subprocess.run([str(SYNC)], env=env, capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    assert (home / ".agents/skills/stray-skill/SKILL.md").exists()
    assert (home / ".agents/skills/vendored-skill/SKILL.md").exists()
    assert "stray-skill" in result.stdout and "vendored-skill" not in result.stdout

    # Armed: untracked directories go; chezmoi-managed ones stay.
    (home / ".agents/.skills-prune-armed").touch()
    result = subprocess.run([str(SYNC)], env=env, capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    assert not (home / ".agents/skills/stray-skill").exists()
    assert (home / ".agents/skills/vendored-skill/SKILL.md").exists()
    assert "Pruned stray-skill" in result.stdout

    # SKILLS_PRUNE=0 skips pruning entirely.
    (home / ".agents/skills/stray-skill").mkdir()
    result = subprocess.run([str(SYNC)], env={**env, "SKILLS_PRUNE": "0"},
                            capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    assert (home / ".agents/skills/stray-skill").exists()

    # --no-prune behaves like SKILLS_PRUNE=0.
    result = subprocess.run([str(SYNC), "--no-prune"], env=env,
                            capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    assert (home / ".agents/skills/stray-skill").exists()

    # A failed restore aborts before any pruning.
    (home / "call").unlink()
    result = subprocess.run([str(SYNC)], env={**env, "SKILLS_EXIT": "7"},
                            capture_output=True, text=True)
    assert result.returncode != 0
    assert (home / ".agents/skills/stray-skill").exists()

print("PASS: pinned lock, frozen install in ~/.agents, dry-run-then-armed pruning, "
      "vendored-skill exemption, prune switches, failure abort")
