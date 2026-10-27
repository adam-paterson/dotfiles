-- nvim --headless -u NONE -l tests/test_nvim_typescript.lua
-- Requires the installed typescript-language-server and editor-owned JS SDK.
local repo = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
local sdk = vim.fn.stdpath("config") .. "/tools/node_modules/typescript"
local directory = vim.fn.tempname() .. " typescript projects"
local clients = {}

local function check()
  assert(vim.fn.executable("typescript-language-server") == 1, "Install the mise language server first")
  assert(vim.uv.fs_stat(sdk .. "/lib/tsserver.js"), "Install the editor tools first")
  local sdk_version = vim.json.decode(table.concat(vim.fn.readfile(sdk .. "/package.json"), "\n")).version
  for _, scenario in ipairs({ "no-sdk", "native-only", "workspace-js", "hoisted-js" }) do
    local base = directory .. "/" .. scenario
    local project = scenario == "hoisted-js" and base .. "/packages/app" or base
    vim.fn.mkdir(project, "p")
    if scenario == "native-only" then
      vim.fn.mkdir(base .. "/node_modules/typescript/lib", "p")
      vim.fn.writefile({ '{"name":"typescript","version":"7.0.0"}' }, base .. "/node_modules/typescript/package.json")
    elseif scenario == "workspace-js" or scenario == "hoisted-js" then
      vim.fn.mkdir(base .. "/node_modules", "p")
      assert(vim.uv.fs_symlink(sdk, base .. "/node_modules/typescript"))
    end
    vim.fn.writefile({ '{"compilerOptions":{"strict":true}}' }, project .. "/tsconfig.json")
    vim.fn.writefile({ 'const value: string = 42;', 'const text = "hello";', 'text.' }, project .. "/example.ts")
    vim.cmd.edit(vim.fn.fnameescape(project .. "/example.ts"))
    vim.bo.filetype = "typescript"
    local bufnr = vim.api.nvim_get_current_buf()
    local version
    local config = vim.tbl_deep_extend("force", {
      name = "ts_ls",
      cmd = { "typescript-language-server", "--stdio" },
      root_dir = project,
      init_options = { hostInfo = "neovim" },
      handlers = {
        ["$/typescriptVersion"] = function(_, result) version = result end,
      },
    }, dofile(repo .. "/src/dot_config/nvim/after/lsp/ts_ls.lua"))
    local id = assert(vim.lsp.start(config))
    local client = assert(vim.lsp.get_client_by_id(id))
    table.insert(clients, client)
    assert(vim.wait(10000, function() return client.initialized and version ~= nil end, 20),
      scenario .. ": TypeScript server did not initialize")
    local workspace = scenario == "workspace-js" or scenario == "hoisted-js"
    assert(version.source == (workspace and "workspace" or "user-setting"),
      scenario .. ": incorrect SDK selection: " .. vim.inspect(version))
    assert(version.version == sdk_version, scenario .. ": incorrect SDK version: " .. vim.inspect(version))
    assert(vim.wait(10000, function()
      for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
        if diagnostic.code == 2322 and diagnostic.lnum == 0 then return true end
      end
      return false
    end, 50), scenario .. ": missing string/number type-error diagnostic")
    local response = client:request_sync("textDocument/completion", {
      textDocument = { uri = vim.uri_from_bufnr(bufnr) },
      position = { line = 2, character = 5 },
      context = { triggerKind = 1 },
    }, 5000, bufnr)
    assert(response and not response.err, vim.inspect(response))
    local matched = false
    local result = response.result or {}
    for _, item in ipairs(result.items or result) do
      if item.label == "toUpperCase" then matched = true end
    end
    assert(matched, scenario .. ": missing string-method completion")
    client:stop(true)
    assert(vim.wait(5000, function() return client:is_stopped() end, 20))
    vim.api.nvim_buf_delete(bufnr, { force = true })
    print("PASS: " .. scenario .. " SDK selection, diagnostics, and completion")
  end
end

local ok, err = xpcall(check, debug.traceback)
for _, client in ipairs(clients) do client:stop(true) end
vim.wait(5000, function()
  for _, client in ipairs(clients) do if not client:is_stopped() then return false end end
  return true
end, 20)
vim.fn.delete(directory, "rf")
if not ok then print(err); vim.cmd("cquit 1") end
