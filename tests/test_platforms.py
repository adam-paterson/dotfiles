"""Run with python3 tests/test_platforms.py; requires chezmoi and Fish."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import tomllib

SOURCE = Path(__file__).resolve().parents[1] / "src"
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    source = root / "source"
    source.mkdir()
    shutil.copy(SOURCE / ".chezmoiignore", source)
    shutil.copy(SOURCE / ".chezmoiremove", source)
    for name in [".chezmoidata", "dot_config/aerospace", "dot_config/private_fish", "dot_config/ghostty",
                 "dot_config/tableplus",
                 "dot_config/herdr", "dot_config/mise", "dot_config/git", "dot_pi", "private_dot_homebrew"]:
        shutil.copytree(SOURCE / name, source / name)
    # Accidental captures must stay ignored even if they reappear in the source.
    for name in ["dot_config/borders/executable_bordersrc", "dot_config/private_spotatui/private_config.yml"]:
        path = source / name
        path.parent.mkdir(parents=True)
        path.write_text("desktop-only configuration\n")
    (source / "dot_config/private_fish/private_fish_variables").write_text("captured Mac state\n")
    metadata = source / "dot_config/nvim/dot_git/config"
    metadata.parent.mkdir(parents=True)
    metadata.write_text("captured git metadata\n")
    shutil.copy(SOURCE / "dot_config/nvim/nvim-pack-lock.json", metadata.parent.parent)
    for name in ["dot_config/nvim/plugin/41_dotnet.lua",
                 ".chezmoiscripts/run_onchange_after_92-install-roslyn.sh.tmpl"]:
        target = source / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(SOURCE / name, target)
    for platform, hostname in [("linux", "seraph"), ("linux", "SERAPH.example.net"),
                               ("linux", "desktop"), ("darwin", "MACBOOK-002531")]:
        headless = hostname.lower().split(".")[0] == "seraph"
        home = root / hostname
        home.mkdir()
        (home / ".local/bin").mkdir(parents=True)
        (home / ".dotnet/tools").mkdir(parents=True)
        (home / ".config/fish").mkdir(parents=True)
        state = home / ".config/fish/fish_variables"
        state.write_text("# Local runtime state\n")
        config = home / "chezmoi.toml"
        config.write_text("")
        env = {**os.environ, "HOME": str(home), "XDG_CONFIG_HOME": str(home / ".config")}
        cli = ["chezmoi", "--source", str(source), "--destination", str(home),
               "--config", str(config), "--persistent-state", str(home / "state.db"),
               "--override-data", json.dumps({"chezmoi": {
                   "os": platform,
                   "hostname": hostname,
                   "homeDir": str(home),
               }})]
        def run(*args):
            return subprocess.check_output(cli + list(args), env=env, text=True)
        managed = set(run("managed", "--path-style=relative").splitlines())
        assert ".config/fish/fish_variables" not in managed
        assert not any("/.git" in path for path in managed)
        for path in [".homebrew/Brewfile", ".config/aerospace/aerospace.toml", ".config/borders/bordersrc",
                     ".config/fish/conf.d/00-brew.fish",
                     ".config/fish/conf.d/00-orbstack.fish", ".config/fish/completions/orbctl.fish"]:
            assert (path in managed) == (platform == "darwin"), (platform, path)
        for path in [".config/ghostty/config", ".config/tableplus/dracula.tableplustheme",
                     ".config/tableplus/kanagawa.tableplustheme", ".config/spotatui/config.yml",
                     ".config/mise/conf.d/entertainment.toml"]:
            assert (path in managed) == (not headless), (hostname, path)
        for path in [".config/herdr/config.toml", ".config/mise/conf.d/cli.toml",
                     ".config/mise/conf.d/editors.toml", ".config/mise/conf.d/languages.toml"]:
            assert path in managed, (hostname, path)
        sounds = tomllib.loads(run("cat", str(home / ".config/herdr/config.toml")))["ui"]["sound"]
        assert sounds["enabled"] == (not headless)
        assert (".config/herdr/request.mp3" in managed) == (not headless)
        for path in [".config/nvim/plugin/41_dotnet.lua", ".chezmoiscripts/92-install-roslyn.sh"]:
            assert (path in managed) == (not headless), (hostname, path)
        tools = {}
        for name in ["config.toml", "conf.d/ai.toml", "conf.d/cli.toml",
                     "conf.d/languages.toml", "conf.d/security.toml"]:
            tools.update(tomllib.loads(run("cat", str(home / ".config/mise" / name)))["tools"])
        assert "github:microsoft/apm" not in tools
        assert tools["op"] == "2.41.1" and tools["pnpm"] == "12.15.0"
        assert tools["npm:@github/copilot-language-server"] == ("1.558.0" if headless else "1.561.0")
        for name in ["npm:gentle-pi", "cargo:plannotator-tui", "npm:@colbymchenry/codegraph",
                     "npm:@doist/todoist-cli", "oxlint", "pipx:sqlfluff", "viteplus"]:
            assert (name in tools) == (not headless), (hostname, name)
        assert tools["cloc"]["platforms"]["linux-arm64"]["asset_pattern"] == "cloc-{{ version }}.pl"
        pi = json.loads(run("cat", str(home / ".pi/agent/settings.json")))
        if headless:
            assert not pi["subagents"].get("disableBuiltins", False)
            assert len(pi["subagents"]["agentOverrides"]) == 8
            assert pi["subagents"]["agentOverrides"]["scout"]["tools"] == ["read", "grep", "find", "ls"]
            assert "npm:pi-mcp-adapter" in pi["packages"]
            assert "defaultTools" not in pi
        else:
            assert pi["subagents"]["disableBuiltins"]
            assert pi["subagents"]["agentOverrides"] == {}
            assert pi["defaultTools"] == ["+codemode"]
        git_config = run("cat", str(home / ".config/git/config"))
        signer = subprocess.check_output(
            ["git", "config", "--file", "/dev/stdin", "--get", "gpg.ssh.program"],
            input=git_config, text=True).strip()
        assert signer == ("/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
                          if platform == "darwin" else "ssh-keygen"), (hostname, signer)
        signing_key = subprocess.check_output(
            ["git", "config", "--file", "/dev/stdin", "--get", "user.signingkey"],
            input=git_config, text=True).strip()
        public_key = ("ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDqy5RHK2B2P6JjMR8zbc4xjUgW0ZAVRISv3fvyLIWf"
                      if headless else
                      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL1CJVWAx5tlEl1onIshZURohd68JMza5uk1E+eStOUn")
        assert signing_key == (str(home / ".ssh/id_ed25519") if headless else public_key)
        assert run("cat", str(home / ".config/git/allowed_signers")).strip() == (
            "hello@adampaterson.co.uk " + public_key)
        lock = json.loads(run("cat", str(home / ".config/nvim/nvim-pack-lock.json")))
        assert "diffview.nvim" in lock["plugins"]
        if not headless:
            ghostty = run("cat", str(home / ".config/ghostty/config"))
            assert ("macos-option-as-alt" in ghostty) == (platform == "darwin")
        run("apply", "--no-tty", "--parent-dirs", "--exclude=scripts", str(home / ".config/fish/conf.d/00-paths.fish"))
        subprocess.run(["fish", "--no-config", "-c",
                        'source "$HOME/.config/fish/conf.d/00-paths.fish"; '
                        'contains -- "$HOME/.local/bin" $PATH; or exit 1; '
                        'contains -- "$HOME/.dotnet/tools" $PATH; or exit 1'],
                       env=env, check=True)
        retired = [home / ".config/fish/conf.d/gtr.fish",
                   home / ".config/fish/completions/git-gtr.fish",
                   home / ".config/fish/conf.d/usage.fish",
                   *(home / ".config/fish/conf.d" / name for name in
                     ["brew.fish", "orbstack.fish", "paths.fish", "00-mise.fish", "zz-nvim.fish"])]
        for path in retired:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("# Retired shell integration\n")
        run("apply", "--no-tty", "--exclude=scripts", *(str(path) for path in retired))
        assert all(not path.exists() for path in retired)
        assert state.read_text() == "# Local runtime state\n"
        print(f"PASS: {hostname} ({platform}) file selection, native paths, shared Diffview, retired hook removal, preserved Fish state")
