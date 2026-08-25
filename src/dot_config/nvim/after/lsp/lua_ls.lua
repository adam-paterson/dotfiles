return {
	on_attach = function(client, buf_id)
		client.server_capabilities.completionProvider.triggerCharacters = { ".", ":", "#", "(" }
	end,

	---@type vim.lsp.Config
	settings = {
		Lua = {
			codeLens = {
				enable = true,
			},
			completion = {
				callSnippet = "Replace",
				keywordSnippet = "Replace",
				showParams = true,
			},
			doc = {
				privateName = { "^_" },
			},
			diagnostics = {
				globals = { "vim" },
			},

			workspace = {
				checkThirdParty = false,
				ignoreSubmodules = true,
				library = { vim.env.VIMRUNTIME },
			},
			hint = {
				enable = true,
				setType = false,
				paramType = true,
				paramName = "Disable",
				semicolon = "Disable",
				arrayIndex = "Disable",
			},
			runtime = {
				version = "LuaJIT",
				path = vim.split(package.path, ";"),
			},
		},
	},
}
