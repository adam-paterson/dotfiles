"""Run with python3 tests/test_platforms.py; requires chezmoi and Fish."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

SOURCE = Path(__file__).resolve().parents[1] / "src"
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    source = root / "source"
    source.mkdir()
    shutil.copy(SOURCE / ".chezmoiignore", source)
    shutil.copy(SOURCE / ".chezmoiremove", source)
    for name in [".chezmoidata", "dot_config/aerospace", "dot_config/private_fish", "dot_config/ghostty"]:
        shutil.copytree(SOURCE / name, source / name)
    # Accidental captures must stay ignored even if they reappear in the source.
    (source / "dot_config/private_fish/private_fish_variables").write_text("captured Mac state\n")
    metadata = source / "dot_config/nvim/dot_git/config"
    metadata.parent.mkdir(parents=True)
    metadata.write_text("captured git metadata\n")
    shutil.copy(SOURCE / "dot_config/nvim/nvim-pack-lock.json", metadata.parent.parent)
    for platform in ["linux", "darwin"]:
        home = root / platform
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
                   "hostname": "MACBOOK-002531" if platform == "darwin" else "seraph",
               }})]
        def run(*args):
            return subprocess.check_output(cli + list(args), env=env, text=True)
        managed = set(run("managed", "--path-style=relative").splitlines())
        assert ".config/fish/fish_variables" not in managed
        assert not any("/.git" in path for path in managed)
        for path in [".config/aerospace/aerospace.toml", ".config/fish/conf.d/00-brew.fish",
                     ".config/fish/conf.d/00-orbstack.fish", ".config/fish/completions/orbctl.fish"]:
            assert (path in managed) == (platform == "darwin"), (platform, path)
        lock = json.loads(run("cat", str(home / ".config/nvim/nvim-pack-lock.json")))
        assert "diffview.nvim" in lock["plugins"]
        ghostty = run("cat", str(home / ".config/ghostty/config"))
        assert ("macos-option-as-alt" in ghostty) == (platform == "darwin")
        run("apply", "--no-tty", "--parent-dirs", str(home / ".config/fish/conf.d/00-paths.fish"))
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
        print(f"PASS: {platform} file selection, native paths, shared Diffview, retired hook removal, preserved Fish state")
