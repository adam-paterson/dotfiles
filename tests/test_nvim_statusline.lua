-- With the deployed config: nvim --headless '+lua dofile("tests/test_nvim_statusline.lua")'
-- Drive actual editor modes and inspect the rendered statusline, not a mock.
local cases = {
  { keys = "", label = "Normal", group = "MiniStatuslineModeNormal" },
  { keys = "i", label = "Insert", group = "MiniStatuslineModeInsert" },
  { keys = "<Esc>v", label = "Visual", group = "MiniStatuslineModeVisual" },
  { keys = "<Esc>", label = "Normal", group = "MiniStatuslineModeNormal" },
}
local backgrounds = {}
local function fail(err)
  print(err)
  vim.cmd("cquit 1")
end
local function step(index)
  local case = cases[index]
  if not case then
    if backgrounds.MiniStatuslineModeNormal == backgrounds.MiniStatuslineModeInsert
      or backgrounds.MiniStatuslineModeInsert == backgrounds.MiniStatuslineModeVisual
      or backgrounds.MiniStatuslineModeNormal == backgrounds.MiniStatuslineModeVisual then
      return fail("Mode backgrounds must be distinct")
    end
    print("PASS: Normal, Insert, Visual labels and distinct highlights")
    vim.cmd("qa!")
    return
  end
  vim.api.nvim_input(case.keys)
  vim.defer_fn(function()
    local ok, err = pcall(function()
      assert(vim.o.laststatus ~= 0, "Statusline is hidden")
      local rendered = vim.api.nvim_eval_statusline(vim.wo.statusline, { winid = 0, highlights = true })
      assert(rendered.str:find(case.label, 1, true), "Missing " .. case.label .. " in: " .. rendered.str)
      local found = false
      for _, hl in ipairs(rendered.highlights) do
        if hl.group == case.group or vim.tbl_contains(hl.groups or {}, case.group) then found = true end
      end
      assert(found, "Missing mode highlight: " .. case.group)
      local hl = vim.api.nvim_get_hl(0, { name = case.group, link = false })
      assert(hl.bg and hl.fg and hl.bg ~= hl.fg, "Mode label must have visible foreground/background")
      backgrounds[case.group] = hl.bg
    end)
    if not ok then return fail(err) end
    step(index + 1)
  end, 150)
end
vim.defer_fn(function()
  vim.cmd.enew()
  vim.o.columns = 160
  step(1)
end, 500)
