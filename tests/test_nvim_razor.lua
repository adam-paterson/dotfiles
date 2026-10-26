-- Run with the deployed config and a restored `dotnet new webapp` fixture:
-- nvim --headless /tmp/fixture/Pages/Index.cshtml \
--   '+lua dofile("tests/test_nvim_razor.lua")'
local function check()
	assert(vim.bo.filetype == "razor", "Open the fixture's Pages/Index.cshtml")
	local buffer = vim.api.nvim_get_current_buf()
	local client
	assert(
		vim.wait(30000, function()
			client = vim.lsp.get_clients({ bufnr = buffer, name = "roslyn" })[1]
			return client and client.initialized
		end, 100),
		"Roslyn did not initialize"
	)
	assert(#vim.lsp.get_clients({ name = "roslyn_ls" }) == 0, "Duplicate C# server")

	-- Ask about the template's @model IndexModel: exercises Razor -> C#,
	-- rather than merely proving the server process started.
	assert(
		vim.wait(30000, function()
			local response = client:request_sync("textDocument/hover", {
				textDocument = { uri = vim.uri_from_bufnr(buffer) },
				position = { line = 1, character = 10 },
			}, 3000, buffer)
			return response
				and not response.err
				and response.result
				and vim.inspect(response.result):find("IndexModel", 1, true)
		end, 250),
		"Razor model hover did not resolve IndexModel"
	)
	-- HTML projections are created on demand by a delegated request.
	vim.lsp.buf_request(buffer, "textDocument/hover", {
		textDocument = { uri = vim.uri_from_bufnr(buffer) },
		position = { line = 6, character = 6 },
	})
	assert(
		vim.wait(10000, function()
			return #vim.lsp.get_clients({ name = "html" }) > 0
		end, 100),
		"Razor's virtual HTML server did not attach"
	)

	-- Verify exclusion even after a solution has been selected in this session.
	vim.g.roslyn_nvim_selected_solution = vim.fn.expand("%:p:h:h") .. "/App.sln"
	local outside = vim.fn.tempname()
	vim.fn.mkdir(outside, "p")
	for _, name in ipairs({
		"Standalone.cs",
		"Standalone.razor",
		"Standalone.cshtml",
		"index.html",
		"Fake__virtual.html",
	}) do
		local buf = vim.fn.bufadd(outside .. "/" .. name)
		vim.fn.bufload(buf)
		local called = false
		local server = name:match("%.html$") and "html" or "roslyn"
		vim.lsp.config[server].root_dir(buf, function()
			called = true
		end)
		assert(not called, "Server accepted unrelated file: " .. name)
		vim.api.nvim_buf_delete(buf, { force = true })
	end
	local plain_html = vim.fn.bufadd(vim.fn.expand("%:p:h") .. "/plain.html")
	local called = false
	vim.lsp.config.html.root_dir(plain_html, function()
		called = true
	end)
	assert(not called, "HTML server accepted a non-projected buffer")
	vim.api.nvim_buf_delete(plain_html, { force = true })
	vim.fn.delete(outside, "d")
	print("PASS: Razor model hover, projected HTML, no duplicate C# server, unrelated files excluded")
end

vim.defer_fn(function()
	local ok, err = xpcall(check, debug.traceback)
	if not ok then
		print(err)
		vim.cmd("cquit 1")
	end
	vim.cmd("qa!")
end, 500)
