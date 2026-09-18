"""Run with python3 tests/test_apm_skills.py; no downloads or real installs."""
import os
from pathlib import Path
import subprocess
import tempfile

SCRIPT = Path(__file__).resolve().parents[1] / "src/.chezmoiscripts/run_after_95-install-apm-skills.sh"
with tempfile.TemporaryDirectory() as directory:
    home = Path(directory)
    binary = home / ".local/bin/mise"
    binary.parent.mkdir(parents=True)
    binary.write_text('#!/bin/sh\nprintf "%s\\n" "$PWD" "$@" > "$HOME/call"\nexit "${APM_EXIT:-0}"\n')
    binary.chmod(0o755)
    env = {**os.environ, "HOME": str(home)}

    def run(**overrides):
        return subprocess.run(["sh", str(SCRIPT)], env={**env, **overrides},
                              capture_output=True, text=True)

    result = run()
    assert result.returncode == 0 and "Skipping APM" in result.stdout
    assert not (home / "call").exists()

    (home / ".apm").mkdir()
    (home / ".apm/apm.yml").write_text("name: global-skills\n")
    assert run().returncode == 0
    assert (home / "call").read_text().splitlines() == [
        str(home), "exec", "--", "apm", "install", "--global", "--frozen", "--only", "apm",
        "--no-trust-bin",
    ]
    assert run(APM_EXIT="1").returncode == 1
    print("PASS: unconfigured skip, frozen skills-only invocation, failure propagation")
