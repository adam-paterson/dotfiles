"""Run with python3 tests/test_fish_startup.py; requires Fish. No real secrets/tools run."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

SOURCE = Path(__file__).resolve().parents[1] / "src/dot_config/private_fish"
FISH = shutil.which("fish")

with tempfile.TemporaryDirectory() as directory:
    home = Path(directory)
    bin_dir = home / ".local/bin"
    tools = home / "tools"
    stale = home / "stale"
    for path in [bin_dir, tools, stale]:
        path.mkdir(parents=True)
    log = home / "calls"
    mise = bin_dir / "mise"
    mise.write_text('''#!/bin/sh
printf 'mise %s\\n' "$*" >> "$CALL_LOG"
[ "$*" = 'activate fish' ] || exit 1
printf 'set -gx PATH "%s/tools" $PATH\\n' "$HOME"
''')
    mise.chmod(0o755)
    atuin = tools / "atuin"
    atuin.write_text('''#!/bin/sh
printf 'atuin %s\\n' "$*" >> "$CALL_LOG"
case "$*" in
'init fish')
    printf '%s\\n' 'function _test_atuin_preexec --on-event fish_preexec; set -g captured_command $argv[1]; end'
    printf '%s\\n' 'function _test_atuin_search; end' 'bind ctrl-r _test_atuin_search'
    ;;
'pty-proxy init fish') ;;
*) exit 1 ;;
esac
''')
    atuin.chmod(0o755)
    for path, output in [(tools / "nvim", "managed"), (stale / "nvim", "stale")]:
        path.write_text(f"#!/bin/sh\nprintf '{output}\\n'\n")
        path.chmod(0o755)

    setup = "; ".join(f'source "{SOURCE / "private_conf.d" / name}"' for name in
                      ["00-paths.fish", "01-mise.fish", "zz-atuin.fish"])
    setup += f'; source "{SOURCE / "config.fish"}"'
    for interactive in [False, True]:
        for herdr in [False, True]:
            log.unlink(missing_ok=True)
            script = setup + '; test (nvim) = managed; or exit 10'
            script += '; not functions -q _test_atuin_preexec; or exit 11'
            if interactive:
                script += '''
; emit fish_prompt
; functions -q _test_atuin_preexec; or exit 12
; bind ctrl-r | string match -q '*_test_atuin_search*'; or exit 13
; emit fish_preexec 'first command'
; test "$captured_command" = 'first command'; or exit 14
; emit fish_prompt
; not functions -q __dotfiles_atuin_init; or exit 15
'''
                if herdr:
                    script += '; test "$ATUIN_PTY_PROXY_FAILED" = 1; or exit 16'
            env = {"HOME": str(home), "XDG_CONFIG_HOME": str(home / ".config"),
                   "PATH": f"{stale}:/usr/bin:/bin", "TERM": "dumb",
                   "CALL_LOG": str(log), **({"HERDR_ENV": "1"} if herdr else {})}
            result = subprocess.run([FISH, "--no-config", *(["--interactive"] if interactive else []),
                                     "-c", script], env=env, capture_output=True, text=True, timeout=10)
            assert result.returncode == 0, (interactive, herdr, result.stderr)
            expected = ["mise activate fish"]
            if interactive:
                expected += ["atuin init fish"]
                if not herdr:
                    expected += ["atuin pty-proxy init fish"]
            assert log.read_text().splitlines() == expected, log.read_text()
    print("PASS: managed tool precedence, one mise activation, deferred Atuin, first-command history, bindings, Herdr, non-interactive shells")
