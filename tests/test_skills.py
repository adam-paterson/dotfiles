"""Run with python3 tests/test_skills.py; no downloads or real installs."""

import json
import os
import subprocess
import tempfile
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "src/.chezmoiscripts/run_onchange_after_95-install-skills.sh.tmpl"
with tempfile.TemporaryDirectory() as directory:
    home = Path(directory).resolve()
    binary = home / ".local/bin/npx"
    binary.parent.mkdir(parents=True)
    binary.write_text(
        '#!/usr/bin/env python3\n'
        'import json, os, pathlib, sys\n'
        'home = pathlib.Path.home()\n'
        '(home / "call").write_text(json.dumps(sys.argv[1:]))\n'
        'if os.environ.get("SKILLS_EXIT"): sys.exit(int(os.environ["SKILLS_EXIT"]))\n'
        'for name in json.loads(pathlib.Path("skills-lock.json").read_text())["skills"]:\n'
        '    if name == os.environ.get("SKILLS_OMIT"): continue\n'
        '    p = pathlib.Path(".agents/skills") / name\n'
        '    p.mkdir(parents=True)\n'
        '    (p / "SKILL.md").write_text("upstream skill\\n")\n'
        '    (p / "asset.txt").write_text("supporting file\\n")\n'
    )
    binary.chmod(0o755)
    env = {**os.environ, "HOME": str(home), "XDG_CONFIG_HOME": str(home / ".config"),
           "CLAUDE_CONFIG_DIR": str(home / ".claude"), "CODEX_HOME": str(home / ".codex")}
    skill = home / ".agents/skills/ast-grep"
    skill.mkdir(parents=True)
    (skill / "SKILL.md").write_text("custom skill\n")
    (skill / "local.txt").write_text("local addition\n")
    (skill.parent / "dangling").symlink_to(home / "missing")
    (skill.parent / "not-a-skill").mkdir()
    lock = home / "skills-lock.json"
    lock.write_text(json.dumps({"version": 1, "skills": {
        name: {"source": "fixture/repo", "sourceType": "github", "computedHash": ""}
        for name in ["ast-grep", "new-skill", "dangling"]
    }}))
    original_lock = lock.read_bytes()

    def run(**overrides):
        # The unrendered template expression is a shell comment.
        return subprocess.run(["sh", str(SCRIPT)], env={**env, **overrides},
                              capture_output=True, text=True)

    result = run()
    assert result.returncode == 0, result.stderr
    assert json.loads((home / "call").read_text()) == ["--yes", "skills@1.7.0", "experimental_install"]
    assert (skill / "SKILL.md").read_text() == "custom skill\n"
    assert (skill / "local.txt").read_text() == "local addition\n"
    assert (skill.parent / "dangling").is_symlink()
    assert (skill.parent / "new-skill/asset.txt").read_text() == "supporting file\n"
    assert lock.read_bytes() == original_lock
    (home / "call").unlink()
    assert run().returncode == 0
    assert not (home / "call").exists(), "Reruns must not update existing skills"
    assert not (home / ".config/agents/skills/new-skill").exists(), "Amp already discovers the canonical skill"
    for agent in (".claude", ".codex", ".cursor", ".gemini",
                  ".copilot", ".config/opencode", ".pi/agent", ".continue", ".factory", ".kiro"):
        target = home / agent / "skills"
        assert (target / "ast-grep").is_symlink()
        assert (target / "ast-grep").resolve() == skill
        assert not (target / "not-a-skill").exists()
        assert (target / "new-skill/asset.txt").read_text() == "supporting file\n"

    # Respect non-default harness homes without touching their model settings.
    config = home / "custom config"
    claude = home / "custom claude"
    codex = home / "custom codex"
    for directory in (config, claude, codex):
        directory.mkdir()
        (directory / "settings.json").write_text('"host-specific model"')
    assert run(XDG_CONFIG_HOME=str(config), CLAUDE_CONFIG_DIR=str(claude),
               CODEX_HOME=str(codex)).returncode == 0
    for directory in (config / "opencode", claude, codex):
        assert (directory / "skills/new-skill").resolve() == skill.parent / "new-skill"
    for directory in (config, claude, codex):
        assert (directory / "settings.json").read_text() == '"host-specific model"'

    # Reruns preserve existing links and agent-specific copies.
    target = home / ".claude/skills/ast-grep"
    target.unlink()
    target.mkdir()
    (target / "SKILL.md").write_text("custom version\n")
    assert run().returncode == 0
    assert (target / "SKILL.md").read_text() == "custom version\n"
    target = home / ".pi/agent/skills/ast-grep"
    target.unlink()
    target.symlink_to(home / "missing-user-target")
    assert run().returncode == 0
    assert target.readlink() == home / "missing-user-target"

    selected = json.loads(lock.read_text())
    selected["skills"].update({name: {} for name in ["pending", "missing"]})
    lock.write_text(json.dumps(selected))
    assert run(SKILLS_EXIT="7").returncode != 0
    assert run(SKILLS_OMIT="missing").returncode != 0
    assert not (skill.parent / "pending").exists(), "Partial restore must not publish any new skills"
    assert not (skill.parent / "missing").exists()
    lock.write_text("{invalid")
    assert run().returncode != 0
    print("PASS: additive restore, complete payloads, preserved skills/links/metadata, idempotency, partial failure rejection")
