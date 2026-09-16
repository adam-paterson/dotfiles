"""Run with python3 tests/test_debug_workflow.py; requires nvim and installed plugins.

Checks the frontend without starting an adapter or changing applied dotfiles.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

SOURCE = Path(__file__).resolve().parents[1] / "src/dot_config/nvim"
NVIM = subprocess.check_output(
    ["nvim", "--headless", "--clean", "-i", "NONE", "-c", "lua io.write(vim.v.progpath)", "-c", "qa"],
    text=True,
).strip()

with tempfile.TemporaryDirectory(prefix="debug-workflow-") as directory:
    root = Path(directory)
    shutil.copytree(SOURCE, root / "config/nvim")
    script = root / "check.lua"
    script.write_text(r'''
vim.defer_fn(function()
 local ok, err = pcall(function()
  assert(vim.wait(5000, function() return vim.fn.maparg(" du", "n") ~= "" end), "debug setup missing")
  local dap, dapui = require("dap"), require("dapui")
  local function press(key)
   vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "xt", false)
  end
  local function has_debug_window()
   for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if ft:match("^dapui_") then return true end
   end
   return false
  end

  vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.getcwd() .. "/example.cs"))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {"class Example {}"})
  local buf = vim.api.nvim_get_current_buf()
  local function gutter_sign()
   local placed = vim.fn.sign_getplaced(buf, {group="*"})[1].signs
   assert(#placed == 1, "expected one gutter sign")
   return vim.fn.sign_getdefined(placed[1].name)[1]
  end
  press(" db")
  assert(#require("dap.breakpoints").get(buf)[buf] == 1, "breakpoint not set")
  assert(vim.trim(gutter_sign().text) == "", "breakpoint icon missing")
  assert(gutter_sign().numhl == "DiagnosticError", "breakpoint number highlight missing")
  press("<F9>")
  assert(#(require("dap.breakpoints").get(buf)[buf] or {}) == 0, "breakpoint not removed")

  local input = vim.ui.input
  vim.ui.input = function(_, callback) callback(nil) end
  press(" dB")
  assert(#(require("dap.breakpoints").get(buf)[buf] or {}) == 0, "cancel added a breakpoint")
  vim.ui.input = function(_, callback) callback("count > 2") end
  press(" dB")
  assert(require("dap.breakpoints").get(buf)[buf][1].condition == "count > 2")
  vim.ui.input = input
  assert(vim.trim(gutter_sign().text) == "", "conditional breakpoint icon missing")
  for _, name in ipairs({"BreakpointRejected", "LogPoint", "Stopped"}) do
   local sign = vim.fn.sign_getdefined("Dap" .. name)[1]
   assert(sign and vim.fn.char2nr(sign.text) > 127, name .. " icon missing")
   assert(vim.fn.strdisplaywidth(sign.text) <= 2, name .. " icon too wide")
  end
  assert(vim.fn.sign_getdefined("DapStopped")[1].linehl == "debugPC", "paused line highlight missing")
  for _, key in ipairs({"db", "dB", "dc", "dn", "di", "do", "dt", "dl", "dr", "du", "de"}) do
   local desc = vim.fn.maparg(" " .. key, "n", false, true).desc
   assert(desc and vim.fn.char2nr(desc) > 127, key .. " prompt icon missing")
  end

  assert(not has_debug_window())
  -- Exercise our lifecycle callbacks with real UI windows, without an adapter.
  dap.listeners.after.event_initialized.dapui_config()
  assert(has_debug_window(), "session initialization did not open the UI")
  dap.listeners.before.event_terminated.dapui_config()
  assert(not has_debug_window(), "termination did not close the UI")
  press(" du")
  assert(has_debug_window(), "cannot reopen UI after termination")
  dap.listeners.before.event_exited.dapui_config()
  assert(not has_debug_window(), "exit did not close the UI")
  assert(vim.fn.maparg(" de", "x") ~= "", "selection evaluation missing")
 end)
 if not ok then print(err); vim.cmd("cquit 1") else print("PASS: debug frontend"); vim.cmd("qa!") end
end, 100)
''')
    result = subprocess.run(
        [NVIM, "--headless", "-i", "NONE", "-c", f"luafile {script}"],
        cwd=root,
        env={**os.environ, "XDG_CONFIG_HOME": str(root / "config")},
        capture_output=True, text=True, timeout=30,
    )
    print(result.stdout + result.stderr)
    assert result.returncode == 0, "debug frontend check failed"
