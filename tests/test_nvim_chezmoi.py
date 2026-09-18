"""Real chezmoi + headless Neovim checks, isolated from the user's dotfiles."""
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest


class ChezmoiBuffers(unittest.TestCase):
    def test_redirect_bindings_and_apply(self):
        nvim, chezmoi = shutil.which("nvim"), shutil.which("chezmoi")
        plugins = Path.home() / ".local/share/nvim/site/pack/core/opt"
        if not nvim or not chezmoi or not (plugins / "chezmoi.nvim").is_dir():
            self.skipTest("Requires Neovim, chezmoi, and the installed chezmoi.nvim plugin")
        config = Path(__file__).resolve().parents[1] / "src/dot_config/nvim/plugin/51_chezmoi.lua"
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            source, destination, bin_dir = (root / name for name in ("source", "home", "bin"))
            for path in (source, destination, bin_dir):
                path.mkdir()
            (source / "dot_example").write_text("before\n")
            (destination / ".example").write_text("before\n")
            (source / "dot_template.tmpl").write_text('{{ "rendered" }}\n')
            (destination / ".template").write_text("rendered\n")
            (destination / "ordinary").write_text("unmanaged\n")
            (source / "dot_direct source").write_text("direct\n")
            (destination / ".direct source").write_text("direct\n")
            settings = root / "chezmoi.toml"
            settings.write_text(f"sourceDir = {json.dumps(str(source))}\ndestDir = {json.dumps(str(destination))}\n")
            wrapper = bin_dir / "chezmoi"
            wrapper.write_text("#!/bin/sh\nexec " + shlex.join([
                chezmoi, "--config", str(settings), "--persistent-state", str(root / "state.db"),
                "--cache", str(root / "cache"), "--no-tty",
            ]) + ' "$@"\n')
            wrapper.chmod(0o755)
            lua = root / "check.lua"
            lua.write_text(f"""
vim.opt.rtp:prepend({json.dumps(str(plugins / 'plenary.nvim'))})
vim.opt.rtp:prepend({json.dumps(str(plugins / 'chezmoi.nvim'))})
vim.g.mapleader = ' '
local notices = {{}}
vim.notify = function(message) table.insert(notices, message) end
require('chezmoi').setup({{ edit = {{ watch = true, force = false }} }})
dofile({json.dumps(str(config))})
local source = {json.dumps(str(source))}
local destination = {json.dumps(str(destination))}
local function open(path)
  vim.cmd.edit({{ args = {{path}} }})
  vim.wait(100, function() return false end)
end
local function binding(key)
  return vim.fn.maparg(' c' .. key, 'n', false, true)
end
open(destination .. '/ordinary')
assert(vim.api.nvim_buf_get_name(0) == destination .. '/ordinary')
assert(vim.tbl_isempty(binding('a')), 'Unmanaged file gained bindings')
open(destination .. '/.example')
assert(vim.api.nvim_buf_get_name(0) == source .. '/dot_example', 'Destination did not redirect')
assert(binding('a').buffer == 1 and binding('d').buffer == 1 and binding('w').buffer == 1)
assert(vim.iter(notices):any(function(msg) return msg:find('opened source instead of', 1, true) end))
vim.api.nvim_buf_set_lines(0, 0, -1, false, {{'after'}})
vim.cmd.write()
assert(vim.wait(3000, function() return vim.fn.readfile(destination .. '/.example')[1] == 'after' end), 'Save did not apply')
binding('w').callback()
vim.api.nvim_buf_set_lines(0, 0, -1, false, {{'paused'}})
vim.cmd.write()
vim.wait(100, function() return false end)
assert(vim.fn.readfile(destination .. '/.example')[1] == 'after', 'Watch toggle did not pause apply')
local source_buf = vim.api.nvim_get_current_buf()
binding('d').callback()
assert(vim.bo.filetype == 'diff' and vim.bo.buftype == 'nofile', 'Diff did not open')
assert(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\\n'):find('+paused', 1, true))
vim.cmd.close()
assert(vim.api.nvim_get_current_buf() == source_buf)
binding('a').callback()
assert(vim.fn.readfile(destination .. '/.example')[1] == 'paused', 'Manual apply failed')
binding('w').callback()
assert(#vim.api.nvim_get_autocmds({{group='chezmoi', event='BufWritePost', buffer=source_buf}}) == 1)
open(destination .. '/.template')
assert(vim.api.nvim_buf_get_name(0) == source .. '/dot_template.tmpl', 'Template did not redirect')
open(source .. '/dot_direct source')
assert(binding('a').buffer == 1, 'Fresh direct source open lacks bindings')
open(destination .. '/.direct source')
assert(vim.api.nvim_buf_get_name(0) == source .. '/dot_direct source', 'Path with spaces did not redirect')
assert(binding('a').buffer == 1)
open(destination .. '/ordinary')
assert(vim.tbl_isempty(binding('a')), 'Bindings leaked between buffers')
-- An edit before the scheduled detection must never be discarded.
vim.cmd.edit({{args={{destination .. '/.example'}}}})
vim.api.nvim_buf_set_lines(0, 0, -1, false, {{'unsaved'}})
vim.wait(100, function() return false end)
assert(vim.api.nvim_buf_get_name(0) == destination .. '/.example' and vim.bo.modified)
assert(vim.api.nvim_get_current_line() == 'unsaved')
print('PASS: redirect, templates, local mappings, auto-apply, diff, watch toggle, manual apply, unsaved protection')
""")
            result = subprocess.run(
                [nvim, "--headless", "-u", "NONE", "--noplugin", "-l", str(lua)],
                env={**os.environ, "PATH": str(bin_dir) + os.pathsep + os.environ["PATH"]},
                text=True, capture_output=True, timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
