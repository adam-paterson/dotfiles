-- Run from the chezmoi repository: nvim --headless -u NONE -l tests/test_nvim_formatting.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(vim.fn.expand("~/.local/share/nvim/site/pack/core/opt/conform.nvim"))
local conform = require("conform")

-- Load the real formatter setup without starting unrelated language servers/plugins.
local source = table.concat(vim.fn.readfile(root .. "/src/dot_config/nvim/plugin/40_languages.lua"), "\n")
local setup = assert(source:match('(require%("conform"%).setup%(%b{}%))'))
assert(loadstring(setup))()

local function buffer(name, ft, lines)
  vim.cmd.enew({ bang = true })
  vim.api.nvim_buf_set_name(0, vim.fn.tempname() .. name)
  vim.bo.filetype = ft
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

buffer(".astro", "astro", { "---", "const x=1", "---", "<div>hello</div>" })
local astro_error
conform.format({ async = false, timeout_ms = 5000 }, function(err) astro_error = err end)
assert(not astro_error, tostring(astro_error))
assert(vim.tbl_contains(vim.api.nvim_buf_get_lines(0, 0, -1, false), "const x = 1;"),
  "Astro must format through its editor-owned Prettier plugin, without a project plugin or LSP")

buffer(".ts", "typescript", { "const x={a:1}" })
local project = vim.fn.tempname()
vim.fn.mkdir(project .. "/node_modules/.bin", "p")
local formatter = project .. "/node_modules/.bin/oxfmt"
vim.fn.writefile({ "#!/bin/sh", "printf 'project formatter\\n'" }, formatter)
vim.fn.setfperm(formatter, "rwx------")
vim.api.nvim_buf_set_name(0, project .. "/example.ts")
local project_error
conform.format({ async = false }, function(err) project_error = err end)
assert(not project_error, tostring(project_error))
assert(vim.api.nvim_get_current_line() == "project formatter", "Project-local oxfmt must take precedence")
vim.fn.delete(project, "rf")

-- Exercise both real mappings with a formatter slower than the old 500 ms limit.
local mappings = {}
local function noop() end
Config = {
  icons = {}, icon = function() return "" end, nmap = noop, imap_expr = noop,
  nmap_leader = function(key, rhs) mappings["n" .. key] = rhs end,
  xmap_leader = function(key, rhs) mappings["x" .. key] = rhs end, tmap_leader = noop,
}
dofile(root .. "/src/dot_config/nvim/plugin/10_keymaps.lua")
conform.formatters.slow_test = {
  command = "sh", args = { "-c", "sleep 0.7; printf 'formatted\\n'" }, stdin = true,
}
conform.formatters_by_ft.test_formatting = { "slow_test" }
for _, mode in ipairs({ "n", "x" }) do
  buffer(".txt", "test_formatting", { "before" })
  local command = assert(mappings[mode .. "lf"]):match("^<Cmd>(.*)<CR>$")
  local start = vim.uv.hrtime()
  vim.cmd(command)
  assert((vim.uv.hrtime() - start) / 1e6 < 500, "Manual formatting blocked the editor")
  assert(vim.wait(3000, function() return vim.api.nvim_get_current_line() == "formatted" end),
    "Manual formatting timed out before the formatter completed")
end

-- Check the installed mise-managed formatter on actual TypeScript and Markdown input.
for _, case in ipairs({
  { ".ts", "typescript", { "const x={a:1}" }, "const x = { a: 1 };" },
  { ".md", "markdown", { "# Hello", "", "some   text" }, "some text" },
}) do
  buffer(case[1], case[2], case[3])
  local err
  conform.format({ async = false, timeout_ms = 5000 }, function(e) err = e end)
  assert(not err, tostring(err))
  assert(vim.tbl_contains(vim.api.nvim_buf_get_lines(0, 0, -1, false), case[4]), "Unexpected formatted output")
end

-- Standalone SQL supports SQL Server; projects can select another dialect.
local sql_project = vim.fn.tempname()
vim.fn.mkdir(sql_project, "p")
vim.fn.writefile({ "[sqlfluff]", "dialect = postgres" }, sql_project .. "/.sqlfluff")
for _, case in ipairs({
  { "select a,b from users where id=1;",
    { "select", "    a,", "    b", "from users", "where id = 1;" } },
  { "CREATE TABLE [registry].[Application] (\n[Id] int NOT NULL\n);",
    { "CREATE TABLE [registry].[Application] (", "    [Id] int NOT NULL", ");" } },
  { "select top 5 a,b from dbo.users;",
    { "select top 5", "    a,", "    b", "from dbo.users;" } },
  { "select id::integer from users;",
    { "select id::integer from users;" }, sql_project .. "/query.sql" },
}) do
  buffer(".sql", "sql", vim.split(case[1], "\n"))
  if case[3] then vim.api.nvim_buf_set_name(0, case[3]) end
  local err
  conform.format({ async = false, timeout_ms = 5000 }, function(e) err = e end)
  assert(not err, tostring(err))
  local actual = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  assert(vim.deep_equal(actual, case[2]), "Unexpected SQL output: " .. vim.inspect(actual))
end
vim.fn.delete(sql_project, "rf")
print("PASS: Astro, project formatter precedence, nonblocking mappings, TypeScript, Markdown, standalone SQL and project SQL dialect")
