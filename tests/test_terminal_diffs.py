"""Exercise the configured diff tools in disposable repositories and homes."""

import json
import os
import re
import shlex
import subprocess
import tempfile
from pathlib import Path

import tomllib

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"


def check():
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory).resolve()
        repo = root / "repo"
        repo.mkdir()
        env = {key: value for key, value in os.environ.items()
               if not key.startswith(("GIT_", "DFT_", "WORKTRUNK_"))}
        env.update(
            GIT_CONFIG_GLOBAL=str(root / "gitconfig"),
            GIT_CONFIG_NOSYSTEM="1", GIT_PAGER="cat", DFT_COLOR="never",
            WORKTRUNK_CONFIG_PATH=str(SRC / "dot_config/worktrunk/private_config.toml"),
            WORKTRUNK_SYSTEM_CONFIG_PATH=str(root / "absent.toml"),
            WORKTRUNK_PROJECT_CONFIG_PATH=str(root / "absent.toml"),
        )

        def run(*args, input=None):
            result = subprocess.run(args, cwd=repo, env=env, input=input,
                                    capture_output=True, text=True, timeout=30, check=False)
            assert result.returncode == 0, f"{args}: {result.stdout}\n{result.stderr}"
            return result.stdout

        def structural(output):
            assert "Python" in output and "after_value" in output, output
            assert "diff --git" not in output, output

        (root / "gitconfig").write_text(run(
            "chezmoi", "execute-template", input=(SRC / "dot_config/git/config.tmpl").read_text()))
        run("git", "init", "-b", "main")
        run("git", "config", "commit.gpgsign", "false")
        run("git", "config", "core.hooksPath", str(root / "no-hooks"))
        file = repo / "example file.py"
        file.write_text("answer = 'before_value'\n")
        run("git", "add", ".")
        run("git", "commit", "-m", "Before")
        file.write_text("answer = 'before_value'\nextra = 'added_value'\n")
        for args in [("diff",), ("difftool",), ("ddiff",), ("dft",)]:
            output = run("git", *args)
            assert output.count("before_value") == 2 and "added_value" in output, output
        file.write_text("answer = 'after_value'\n")
        structural(run("git", "diff"))
        structural(run("git", "difftool"))  # Must not prompt.
        structural(run("wt", "step", "diff", "main"))
        run("git", "add", ".")
        structural(run("git", "diff", "--cached"))
        assert "diff --git" in run("git", "diff", "--cached", "--no-ext-diff")
        run("git", "commit", "-m", "After")
        for args in [("show", "--ext-diff"), ("log", "-1", "-p", "--ext-diff"),
                     ("ds",), ("dl", "-1")]:
            structural(run("git", *args))
        assert "diff --git" in run("git", "show")
        assert run("git", "config", "core.pager").strip() == "less -R"
        print("PASS: Git working/staged diffs, difftool, history aliases, Worktrunk step diff")

        # Worktrunk's picker takes patches, not pairs of files.
        wt = tomllib.loads((SRC / "dot_config/worktrunk/private_config.toml").read_text())
        patch = run("git", "show", "--format=", "--no-ext-diff")
        rendered = run(*shlex.split(wt["switch"]["picker"]["pager"]), input=patch)
        assert "after_value" in rendered, rendered
        print("PASS: Worktrunk patch-preview fallback")

        # Exercise the first renderer, which LazyGit selects by default.
        lazygit = (SRC / "dot_config/lazygit/config.yml").read_text()
        command = re.search(r"diffRenderers:\s+- type: extDiff\s+command: (.+)", lazygit)
        assert command, "LazyGit must default to an external diff renderer"
        before = root / "before.py"
        before.write_text("answer = 'before_value'\n")
        renderer = shlex.split(command[1].replace("{{diffContext}}", "3"))
        structural(run(*renderer, str(before), str(file)))
        print("PASS: LazyGit default renderer")

        source, home = root / "source", root / "home"
        source.mkdir()
        home.mkdir()
        (source / "example.py").write_text(file.read_text())
        (home / "example.py").write_text(before.read_text())
        template = (SRC / ".chezmoi.toml.tmpl").read_text()
        config = root / "chezmoi.toml"
        config.write_text(
            f"sourceDir = {json.dumps(str(source))}\ndestDir = {json.dumps(str(home))}\n"
            + run("chezmoi", "execute-template", "--init", input=template)
        )
        chezmoi = ["chezmoi", "--config", str(config), "--persistent-state", str(root / "state.db"),
                   "--cache", str(root / "cache"), "--no-tty", "--no-pager"]
        structural(run(*chezmoi, "diff"))
        assert "@@" in run(*chezmoi, "diff", "--use-builtin-diff")
        (source / "example.py").write_text(before.read_text() + "extra = 'added_value'\n")
        output = run(*chezmoi, "diff")
        assert output.count("before_value") == 2 and "added_value" in output, output
        print("PASS: chezmoi Difftastic diff and built-in patch escape hatch")


if __name__ == "__main__":
    check()
