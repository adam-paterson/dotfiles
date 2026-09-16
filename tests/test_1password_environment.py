"""Run with python3 tests/test_1password_environment.py; requires chezmoi and Fish.

Only fake secrets are used. The real 1Password CLI is never invoked.
"""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

SOURCE = Path(__file__).resolve().parents[1] / "src"
TEMPLATE = SOURCE / "dot_config/private_fish/private_conf.d/1password.fish.tmpl"
FISH = shutil.which("fish")

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    source = root / "source"
    data_dir = source / ".chezmoidata"
    data_dir.mkdir(parents=True)
    data = data_dir / "onepassword.yaml"
    shutil.copyfile(SOURCE / ".chezmoidata/onepassword.yaml", data)
    # Adding either kind of machine must require only a new data record.
    with data.open("a") as output:
        output.write('\n    travelbook:\n      environment: aaaaaaaaaaaaaaaaaaaaaaaaaa\n      auth: desktop\n'
                     '    buildbox:\n      environment: bbbbbbbbbbbbbbbbbbbbbbbbbb\n      auth: service-account\n'
                     '    bad-auth:\n      environment: aaaaaaaaaaaaaaaaaaaaaaaaaa\n      auth: unsupported\n'
                     '    bad-id:\n      environment: "id; echo unsafe"\n      auth: desktop\n')
    empty_config = root / "chezmoi.toml"
    empty_config.write_text("")
    cli = ["chezmoi", "--source", str(source), "--config", str(empty_config),
           "--persistent-state", str(root / "state.db")]
    bin_dir = root / "bin"
    bin_dir.mkdir()
    op = bin_dir / "op"
    op.write_text(f"#!{sys.executable}\n" + r'''
import json, os, sys
from pathlib import Path
Path(os.environ["CALL_LOG"]).write_text(json.dumps({
    "args": sys.argv[1:], "service_account": bool(os.environ.get("OP_SERVICE_ACCOUNT_TOKEN"))
}))
if os.environ.get("FAIL_OP"):
    sys.stdout.buffer.write(b'OP_TEST_VALUE=partial\0')
    print("FAKE_SECRET_IN_ERROR", file=sys.stderr)
    sys.exit(1)
for flag, name in [("BAD_NAME", "bad-name"), ("READONLY", "status"), ("TRACE_VAR", "fish_trace")]:
    if os.environ.get(flag):
        sys.stdout.buffer.write(b'OP_TEST_VALUE=partial\0' + name.encode() + b'=value\0')
        sys.exit(0)
os.environ.update({
    "OP_TEST_VALUE": "spaces and = signs",
    "OP_TEST_LITERAL": "$(touch " + os.environ["SENTINEL"] + ")",
    "OP_TEST_MULTILINE": "first\nsecond",
    "OP_TEST_QUOTES": "it's \\ (echo pwn)",
    "OP_TEST_EMPTY": "",
})
args = sys.argv[sys.argv.index('--') + 1:]
os.execvp(args[0], args)
''')
    op.chmod(0o755)
    token = root / ".config/op/service-account-token"
    token.parent.mkdir(parents=True)
    token.write_text("fake-token\n")
    token.chmod(0o600)
    env = {"PATH": str(bin_dir) + os.pathsep + os.environ["PATH"], "HOME": str(root),
           "TERM": "dumb", "CALL_LOG": str(root / "calls.json"), "SENTINEL": str(root / "injected")}

    for hostname, environment_id, auth in [
        ("MACBOOK-002531.local", "4nkxoouuuii3ubgohy7ykhqzsm", "desktop"),
        ("Seraph", "wqadrv3ix5cxwrv642dxae6puy", "service-account"),
        ("Travelbook.example", "aaaaaaaaaaaaaaaaaaaaaaaaaa", "desktop"),
        ("buildbox", "bbbbbbbbbbbbbbbbbbbbbbbbbb", "service-account"),
    ]:
        rendered = subprocess.check_output(
            cli + ["--override-data", json.dumps({"chezmoi": {"hostname": hostname}}),
             "execute-template"], input=TEMPLATE.read_text(), text=True,
        )
        config = root / "1password.fish"
        config.write_text(rendered)
        subprocess.run([FISH, "--no-config", "--no-execute", str(config)], check=True)
        for interactive in [False, True]:
            for failure in ["", "FAIL_OP", "BAD_NAME", "READONLY", "TRACE_VAR"]:
                log = root / "calls.json"
                log.unlink(missing_ok=True)
                check = ('test "$OP_TEST_VALUE" = "spaces and = signs"; or exit 10; '
                         'test "$OP_TEST_LITERAL" = \'$(touch ' + env["SENTINEL"] + ')\'; or exit 11; '
                         'string match -qr \'^first\\nsecond$\' -- "$OP_TEST_MULTILINE"; or exit 13; '
                         'test "$OP_TEST_QUOTES" = "it\'s \\\\ (echo pwn)"; or exit 14; '
                         'set -q OP_TEST_EMPTY; and test -z "$OP_TEST_EMPTY"; or exit 15'
                         if interactive and not failure else 'not set -q OP_TEST_VALUE; or exit 12')
                check += '; test (count $OP_TEST_ARRAY) -eq 2; or exit 16'
                if auth == "service-account":
                    check += '; test "$OP_SERVICE_ACCOUNT_TOKEN" = fake-token; or exit 17'
                result = subprocess.run(
                    [FISH, "--no-config", *(["--interactive"] if interactive else []), "-c",
                     f"set -gx OP_TEST_ARRAY one two; source {config}; {check}"],
                    env={**env, **({failure: "1"} if failure else {}),
                         **({"OP_SERVICE_ACCOUNT_TOKEN": "inherited-fake-token"} if auth == "desktop" else {})},
                    capture_output=True, text=True, timeout=10,
                )
                assert result.returncode == 0, (hostname, interactive, failure, result.returncode, result.stderr)
                assert not (root / "injected").exists(), "environment value executed as shell code"
                assert "FAKE_SECRET" not in result.stdout + result.stderr
                assert log.exists() == interactive
                if interactive:
                    call = json.loads(log.read_text())
                    assert call["args"] == ["run", "--environment", environment_id, "--no-masking", "--", "/usr/bin/env", "-0"]
                    assert call["service_account"] == (auth == "service-account")
                    assert ("not loaded" in result.stderr) == bool(failure)
        log.unlink(missing_ok=True)
        traced = subprocess.run(
            [FISH, "--no-config", "--interactive", "-c", f"source {config}; not set -q OP_TEST_VALUE"],
            env={**env, "fish_trace": "1"}, capture_output=True, text=True, timeout=10,
        )
        assert traced.returncode == 0 and not log.exists()
        print(f"PASS: {hostname} selection, auth, literal values, arrays, failures, reserved names, tracing, automation")

    for hostname, error in [
        ("unknown", "No 1Password Environment configured"),
        ("bad-auth", "Unsupported 1Password authentication method"),
        ("bad-id", "Invalid 1Password Environment ID"),
    ]:
        invalid = subprocess.run(
            cli + ["--override-data", json.dumps({"chezmoi": {"hostname": hostname}}), "execute-template"],
            input=TEMPLATE.read_text(), capture_output=True, text=True,
        )
        assert invalid.returncode != 0
        assert error in invalid.stderr
    print("PASS: unknown host and invalid host data rejected")
