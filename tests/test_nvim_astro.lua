-- Integration check with the deployed config and an existing Astro project.
-- No project files are written. Run from the chezmoi repo:
-- nvim --headless /absolute/project/src/pages/index.astro \
--   '+lua dofile("tests/test_nvim_astro.lua")'
local function check()
  assert(vim.bo.filetype == "astro", "Pass an existing Astro file as the Neovim argument")
  local client
  assert(vim.wait(10000, function()
    for _, candidate in ipairs(vim.lsp.get_clients({ bufnr = 0, name = "astro" })) do
      if candidate.initialized then client = candidate; return true end
    end
  end, 50), "Astro language server did not initialize")

  -- Complete the containing directory from a relative parent import.
  local name = vim.fn.expand("%:p:h:t")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "---", 'import Component from "../";', "---", "<div />" })
  -- Let didChange reach the server before asking about the replaced buffer.
  vim.wait(300, function() return false end, 50)
  local response = client:request_sync("textDocument/completion", {
    textDocument = { uri = vim.uri_from_bufnr(0) },
    position = { line = 1, character = #'import Component from "../' },
    context = { triggerKind = 1 },
  }, 5000, 0)
  assert(response and not response.err, vim.inspect(response))
  local result = response.result or {}
  local matched = false
  for _, item in ipairs(result.items or result) do
    if item.label:find(name, 1, true) then matched = true end
  end
  assert(matched, "Import completions did not include the containing directory")
  print("PASS: Astro import path completion")

  vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    "---", "const x={a:1}", "---", '<div    class="hello">hello</div>',
  })
  local mapping = vim.fn.maparg(vim.g.mapleader .. "lf", "n", false, true)
  vim.cmd(assert(mapping.rhs:match("^<Cmd>(.*)<CR>$")))
  assert(vim.wait(5000, function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    return vim.tbl_contains(lines, "const x = { a: 1 };")
      and vim.tbl_contains(lines, '<div class="hello">hello</div>')
  end, 50), "Manual Astro formatting did not format frontmatter and markup")
  print("PASS: manual Astro formatting")
end

-- Let startup and the deferred plugin setup finish before exercising mappings.
vim.defer_fn(function()
  local ok, err = xpcall(check, debug.traceback)
  if not ok then print(err); vim.cmd("cquit 1") end

  -- Exercise typing as well as the protocol: an attached server alone does
  -- not prove that the completion UI is wired up.
  local directory = vim.fn.expand("%:p:h:t")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, {
    "---", 'import Component from "..";', "---", "<div />",
  })
  vim.api.nvim_win_set_cursor(0, { 2, #'import Component from "..' })
  vim.api.nvim_input("i/" .. directory:sub(1, 1))
  vim.defer_fn(function()
    local matched = false
    for _, item in ipairs(vim.fn.complete_info({ "items" }).items) do
      if item.word:find(directory, 1, true) then matched = true end
    end
    if not matched then print("FAIL: automatic import popup"); vim.cmd("cquit 1") end
    print("PASS: automatic import popup")
    vim.cmd("qa!")
  end, 3000)
end, 500)
