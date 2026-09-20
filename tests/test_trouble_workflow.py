"""Run with python3 tests/test_trouble_workflow.py; requires installed Neovim plugins."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

source = Path(__file__).resolve().parents[1] / "src/dot_config/nvim"
nvim = subprocess.check_output(
    ["nvim", "--headless", "--clean", "-i", "NONE", "-c", "lua io.write(vim.v.progpath)", "-c", "qa"],
    text=True,
).strip()

with tempfile.TemporaryDirectory(prefix="trouble-workflow-") as directory:
    root = Path(directory)
    shutil.copytree(source, root / "config/nvim")
    script = root / "check.lua"
    script.write_text(r'''
vim.defer_fn(function()
 local ok, err = pcall(function()
  assert(vim.wait(5000, function() return vim.fn.exists(':Trouble') == 2 and MiniPick ~= nil end))
  local trouble = require('trouble')
  local function press(key)
   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'xt', false)
  end
  local function wait_for_items(mode, count)
   assert(vim.wait(3000, function()
    return trouble.is_open({mode=mode}) and #trouble.get_items({mode=mode}) == count
   end), mode .. ': wrong result count')
   assert(vim.wait(3000, function() return vim.bo.filetype == 'trouble' end), 'Trouble did not receive focus')
  end
  vim.cmd('edit first.txt')
  local first = vim.api.nvim_get_current_buf()
  local main = vim.api.nvim_get_current_win()
  local second = vim.fn.bufadd('second.txt')
  vim.fn.bufload(second)
  local ns = vim.api.nvim_create_namespace('trouble-test')
  for _, buf in ipairs({first, second}) do
   vim.diagnostic.set(ns, buf, {{lnum=0, col=0, message='Test diagnostic', severity=vim.diagnostic.severity.ERROR}})
  end
  press(' xX')
  wait_for_items('diagnostics', 1)
  assert(trouble.get_items({mode='diagnostics'})[1].buf == first, 'Wrong buffer diagnostic')
  trouble.close()
  vim.api.nvim_set_current_win(main)
  press(' xx')
  wait_for_items('diagnostics', 2)
  vim.diagnostic.reset(ns)
  assert(vim.wait(3000, function() return not trouble.is_open({mode='diagnostics'}) end), 'Empty list did not close')
  vim.api.nvim_set_current_win(main)

  -- Exercise mini.pick's native marked-results handoff, without Telescope.
  MiniPick.default_choose_marked({{bufnr=first, lnum=1, col=1, text='Picked result'}})
  assert(#vim.fn.getqflist() == 1, 'Picker did not populate quickfix')
  vim.cmd('cclose')
  press(' xq')
  wait_for_items('qflist', 1)
  trouble.close()
  vim.api.nvim_set_current_win(main)
  vim.fn.setloclist(0, {{bufnr=first, lnum=1, col=1, text='Local result'}})
  press(' xl')
  wait_for_items('loclist', 1)
  trouble.close()
  for _, key in ipairs({'xx', 'xX', 'xq', 'xl', 'xL'}) do
   assert(vim.fn.maparg(' ' .. key, 'n', false, true).desc, key .. ': missing hint')
  end
  assert(vim.fn.maparg(' fS', 'n'):find('Pick lsp', 1, true), 'mini.pick mapping replaced')
 end)
 if not ok then print(err); vim.cmd('cquit 1') else print('PASS: Trouble diagnostics, focus, auto-close, mini.pick quickfix, location list, and hints'); vim.cmd('qa!') end
end, 100)
''')
    result = subprocess.run(
        [nvim, "--headless", "-i", "NONE", "-c", f"luafile {script}"],
        cwd=root, env={**os.environ, "XDG_CONFIG_HOME": str(root / "config")},
        capture_output=True, text=True, timeout=30,
    )
    print(result.stdout + result.stderr)
    assert result.returncode == 0, "Trouble integration check failed"
