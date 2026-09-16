"""Run with python3 tests/test_diff_workflow.py; requires nvim and installed plugins.

Uses the repository's Neovim config with temporary files and a temporary Git repo.
Never saves or applies real dotfiles.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

SOURCE = Path(__file__).resolve().parents[1] / "src/dot_config/nvim"
# Resolve version-manager shims before isolating the config directory.
NVIM = subprocess.check_output(
    ["nvim", "--headless", "--clean", "-i", "NONE", "-c", "lua io.write(vim.v.progpath)", "-c", "qa"],
    text=True,
).strip()

with tempfile.TemporaryDirectory(prefix="diff-workflow-") as directory:
    root = Path(directory)
    shutil.copytree(SOURCE, root / "config/nvim")
    repo = root / "repo"
    repo.mkdir()
    env = {**os.environ, "XDG_CONFIG_HOME": str(root / "config"),
           "GIT_CONFIG_GLOBAL": os.devnull, "GIT_CONFIG_NOSYSTEM": "1"}

    def git(*args, check=True):
        return subprocess.run(
            ["git", "-c", "user.name=Test", "-c", "user.email=test@example.invalid",
             "-c", "commit.gpgsign=false", *args],
            cwd=repo, env=env, check=check, capture_output=True, text=True,
        )

    git("init", "-b", "main")
    file = repo / "example.txt"
    file.write_text("base\n")
    git("add", ".")
    git("commit", "-m", "base")
    git("checkout", "-b", "incoming")
    file.write_text("theirs\n")
    git("commit", "-am", "theirs")
    git("checkout", "main")
    file.write_text("ours\n")
    git("commit", "-am", "ours")
    assert git("merge", "incoming", check=False).returncode == 1

    script = root / "check.lua"
    script.write_text(r'''
vim.defer_fn(function()
 local ok, err = pcall(function()
  assert(vim.wait(5000, function() return vim.fn.exists(":DiffviewOpen") == 2 end))
  local function mapping(key) return vim.fn.maparg(key, "n", false, true) end
  local function press(key)
   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "xt", false)
  end
  for key, rhs in pairs({
   gc="<Cmd>Git commit<CR>", gq="<Cmd>DiffviewClose<CR>",
   gd="<Cmd>DiffviewOpen<CR>", gD="<Cmd>DiffviewOpen -- %<CR>",
   ga="<Cmd>DiffviewOpen --cached<CR>", gA="<Cmd>DiffviewOpen --cached -- %<CR>",
   gh="<Cmd>DiffviewFileHistory<CR>", gH="<Cmd>DiffviewFileHistory %<CR>",
  }) do assert(mapping(" " .. key).rhs == rhs, key) end
  assert(require("chezmoi").config.edit.watch == false)
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds({event="BufReadPost"})) do
   assert(not autocmd.pattern:find("/.local/share/chezmoi/", 1, true), "automatic chezmoi watch")
  end

  if vim.wo.diff then
   assert(Config.is_native_diff())
   press(" gm2")
   local source = vim.api.nvim_get_current_buf()
   assert(vim.fn.expand("%:t") == "source")
   press(" gml")
   assert(vim.api.nvim_buf_get_lines(source, 0, -1, false)[1] == "destination")
   vim.cmd("new")
   assert(vim.wait(1000, function() return vim.fn.maparg(" gm1", "n") == "" end))
  else
   vim.cmd("DiffviewOpen")
   local lib = require("diffview.lib")
   assert(vim.wait(5000, function()
    local view = lib.get_current_view()
    return view and #view.files.conflicting == 1 and vim.wo.diff
      and vim.api.nvim_buf_get_name(0) == vim.fn.getcwd() .. "/example.txt"
      and mapping(" co").callback ~= nil
   end), "conflict view did not open")
   assert(require("diffview.config").get_config().show_help_hints)
   assert(not Config.is_native_diff())
   assert(vim.wait(1000, function() return vim.fn.maparg(" gm1", "n") == "" end))
   assert(vim.fn.maparg(" e", "n") == "", "explorer prefix shadowed")
   assert(vim.fn.maparg(" b", "n") == "", "buffer prefix shadowed")
   assert(mapping(" gf").desc == "Toggle file panel", "toggle mapping")
   assert(mapping(" gF").desc == "Focus file panel", "focus mapping")
   vim.api.nvim_win_set_cursor(0, {1, 0})
   press(" co")
   assert(vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == "ours", "choose ours failed")
   vim.cmd("DiffviewClose")
  end
 end)
 if not ok then print(err); vim.cmd("cquit 1") else print("PASS: diff workflow"); vim.cmd("qa!") end
end, 100)
''')
    for mode in ["git", "native"]:
        args = []
        if mode == "native":
            files = [root / name for name in ["destination", "source", "target"]]
            for path in files:
                path.write_text(path.name + "\n")
            args = ["-d", *map(str, files)]
        result = subprocess.run(
            [NVIM, "--headless", "-i", "NONE", *args, "-c", f"luafile {script}"],
            cwd=repo, env=env, capture_output=True, text=True, timeout=30,
        )
        assert result.returncode == 0, result.stdout + result.stderr
        print(f"PASS: {mode} mappings and conflict/hunk selection")
