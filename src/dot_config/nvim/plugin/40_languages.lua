-- ═══════════════════════════════════════════════════════════
-- LANGUAGE & CODE PLUGINS
-- TS, DAP, LSP configurations for programming languages.
-- ═══════════════════════════════════════════════════════════

local safely = require("mini.misc").safely
local when_args = vim.fn.argc(-1) > 0 and "now" or "later"
local gh = Config.gh

-- ─ Chezmoi templates ─────────────────────────────────────────────
-- *.tmpl files get the filetype of their base name, so e.g.
-- foo.toml.tmpl is treated as toml and gets its LSP + tree-sitter.
Config.new_autocmd({ "BufRead", "BufNewFile" }, "*.tmpl", function(ev)
	local ft = vim.filetype.match({ filename = vim.fn.fnamemodify(ev.file, ":r") })
	if ft then
		vim.bo[ev.buf].filetype = ft
	end
end, "Set filetype from chezmoi template base name")

-- ─ Tree-sitter ─────────────────────────────────────────────────
safely(when_args, function()
	-- Define hook to update tree-sitter parsers after plugin is updated
	local ts_update = function()
		vim.cmd("TSUpdate")
	end
	Config.on_packchanged("nvim-treesitter", { "update" }, ts_update, ":TSUpdate")

	vim.pack.add({
		gh("nvim-treesitter/nvim-treesitter"),
		gh("nvim-treesitter/nvim-treesitter-textobjects"),
	})

	vim.treesitter.language.register("yaml", "yaml.ansible")
	require("nvim-treesitter").setup()

	require("nvim-treesitter-textobjects").setup({
		select = {
			lookahead = true,
		},
		move = {
			set_jumps = true,
		},
	})

	-- Define languages which will have parsers installed and auto enabled
	-- After changing this, restart Neovim once to install necessary parsers. Wait
	-- for the installation to finish before opening a file for added language(s).
	local languages = {
		-- These are already pre-installed with Neovim. Used as an example.
		"bash",
		"css",
		"html",
		"javascript",
		"json",
		"markdown_inline",
		"rust",
		"tsx",
		"typescript",
		"yaml",
		"lua",
		"vimdoc",
		"markdown",
		"astro",
		"c_sharp",
		"json",
		"toml",
	}
	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Enable tree-sitter after opening a file for a target language
	local filetypes = {}
	for _, lang in ipairs(languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	local ts_start = function(ev)
		vim.treesitter.start(ev.buf)
	end
	Config.new_autocmd("FileType", filetypes, ts_start, "Start tree-sitter")
end)

-- ─ Language servers ─────────────────────────────────────────────────
safely(when_args, function()
	vim.pack.add({ gh("neovim/nvim-lspconfig"), gh("b0o/schemastore.nvim") })

	-- Lua LS can complete Neovim and plugin APIs when their source is in its
	-- library. Plugins that publish EmmyLua annotations get the best results.
	vim.lsp.config("lua_ls", {
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
					path = { "lua/?.lua", "lua/?/init.lua" },
				},
				workspace = {
					checkThirdParty = false,
					library = vim.list_extend(
						{ vim.env.VIMRUNTIME },
						vim.fn.glob(vim.fn.stdpath("data") .. "/site/pack/*/*/*", false, true)
					),
				},
			},
		},
	})

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client and client:supports_method("textDocument/completion") then
				vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
			end
		end,
	})

	vim.lsp.enable({ "ansiblels", "astro", "jsonls", "lua_ls", "roslyn_ls", "tailwindcss", "tombi", "ts_ls" })
	vim.lsp.codelens.run()
end)

-- ─ Formatters ─────────────────────────────────────────────────
safely("later", function()
	vim.pack.add({ gh("stevearc/conform.nvim") })

	require("conform").setup({
		default_format_opts = {
			async = true,
			lsp_format = "fallback",
			timeout_ms = 500,
		},
		formatters_by_ft = {
			astro = { "oxfmt", "biome", "prettierd", stop_after_first = true },
			javascript = { "oxfmt", "biome", "prettierd", stop_after_first = true },
			typescript = { "oxfmt", "biome", "prettierd", stop_after_first = true },
			typescriptreact = { "oxfmt", "biome", "prettierd", stop_after_first = true },
			["yaml.ansible"] = { "prettier" },
			lua = { "stylua" },
			toml = { "tombi" },
      markdown = { "oxfmt" },
		},
	})
end)

safely("later", function()
  vim.pack.add({gh("stevearc/aerial.nvim")})

  require("aerial").setup()
end)

safely("later", function()
	vim.pack.add({ gh("folke/trouble.nvim") })

	require("trouble").setup({
		focus = true,
		auto_close = true,
		win = { position = "bottom", size = 10 },
	})
end)

-- ─ Snippets ─────────────────────────────────────────────────
safely("later", function()
	vim.pack.add({ gh("rafamadriz/friendly-snippets"), gh("L3MON4D3/LuaSnip") })

	require("luasnip").setup({
		region_check_events = "CursorMoved,CursorHold,InsertEnter",
		delete_check_events = "TextChanged",
		update_events = "TextChanged,TextChangedI",
		history = true,
		enable_autosnippets = true,
	})

	require("luasnip.loaders.from_vscode").lazy_load()

	require("luasnip.loaders.from_vscode").lazy_load({
		paths = { vim.fn.stdpath("config") .. "/snippets" },
	})

	require("luasnip.loaders.from_lua").lazy_load({
		paths = { vim.fn.stdpath("config") .. "/snippets/lua" },
	})
end)
