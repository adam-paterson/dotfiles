"""Run with python3 tests/test_fish_startup.py; requires Fish and direnv.

Tool startup is mocked; direnv upgrade checks use isolated copies and fake envrcs.
"""
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

with tempfile.TemporaryDirectory(prefix="direnv-upgrade-") as directory:
    root = Path(directory)
    home = root / "home"
    old = root / "old version"
    new = root / "new version"
    for path in [home, old, new]:
        path.mkdir()
    binary = shutil.which("direnv")
    assert binary, "Install direnv before running this test"
    for path in [old, new]:
        shutil.copy2(Path(binary).resolve(), path / "direnv")
    env = {"HOME": str(home), "XDG_CONFIG_HOME": str(home / ".config"),
           "XDG_DATA_HOME": str(home / ".local/share"), "TERM": "dumb",
           "PATH": f"{old}:/usr/bin:/bin"}
    projects = []
    for value in ["prompt", "directory", "preexec"]:
        project = root / value
        project.mkdir()
        (project / ".envrc").write_text(f"export DIRENV_UPGRADE_TEST={value}\n")
        subprocess.run([str(new / "direnv"), "allow", str(project)],
                       env=env, check=True, capture_output=True, text=True)
        projects.append(project)
    script = f'''
source "{SOURCE / 'private_conf.d/direnv.fish'}"
set -gx PATH "{new}" /usr/bin /bin
command rm "{old / 'direnv'}"
emit fish_prompt
test "$DIRENV_UPGRADE_TEST" = prompt; or exit 20
cd "{projects[1]}"
test "$DIRENV_UPGRADE_TEST" = directory; or exit 21
set -g direnv_fish_mode eval_after_arrow
cd "{projects[2]}"
test "$DIRENV_UPGRADE_TEST" = directory; or exit 22
emit fish_preexec
test "$DIRENV_UPGRADE_TEST" = preexec; or exit 23
'''
    result = subprocess.run([FISH, "--no-config", "-c", script], cwd=projects[0],
                            env=env, capture_output=True, text=True, timeout=10)
    assert result.returncode == 0, result.stderr
    assert "Unknown command" not in result.stderr, result.stderr
    print("PASS: prompt, directory-change and preexec hooks survive removal of the old direnv binary")
