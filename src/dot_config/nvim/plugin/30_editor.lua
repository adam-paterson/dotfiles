-- ═══════════════════════════════════════════════════════════
-- EDITOR
-- General editor plugins and configuration
-- ═══════════════════════════════════════════════════════════

local safely = require("mini.misc").safely
local when_args = vim.fn.argc(-1) > 0 and "now" or "later"
local gh, nmap_leader = Config.gh, Config.nmap_leader

safely("now", function()
	require("mini.basics").setup({
		-- Manage options in 'plugin/10_options.lua' for didactic purposes
		options = { basic = false },
		mappings = {
			-- Create `<C-hjkl>` mappings for window navigation
			windows = true,
			-- Create `<M-hjkl>` mappings for navigation in Insert and Command modes
			move_with_alt = true,
		},
	})
end)

-- Miscellaneous small but useful functions.
safely(when_args, function()
	require("mini.misc").setup()

	-- Change current working directory based on the current file path.
	MiniMisc.setup_auto_root()

	-- Restore latest cursor position on file open
	MiniMisc.setup_restore_cursor()

	-- Synchronize terminal emulator background with Neovim's background to remove
	MiniMisc.setup_termbg_sync()
end)

safely("now", function()
	require("mini.sessions").setup()
end)

safely("later", function()
	require("mini.extra").setup()
end)

safely("later", function()
	local ai = require("mini.ai")
	ai.setup({
		custom_textobjects = {
			B = MiniExtra.gen_ai_spec.buffer(),
			F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		},
		search_method = "cover",
	})
end)

safely("later", function()
	require("mini.align").setup()
end)

safely("later", function()
	require("mini.bracketed").setup()
end)

safely("later", function()
	require("mini.bufremove").setup()
end)

safely("later", function()
	require("mini.cursorword").setup()
end)

safely("later", function()
	require("mini.comment").setup()
end)

safely("later", function()
	require("mini.diff").setup()
end)

safely("later", function()
	require("mini.git").setup()
end)

safely("later", function()
	local hipatterns = require("mini.hipatterns")
	local hi_words = MiniExtra.gen_highlighter.words
	hipatterns.setup({
		highlighters = {
			-- Highlight a fixed set of common words. Will be highlighted in any place,
			-- not like "only in comments".
			fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
			hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
			todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
			note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

			-- Highlight hex color string (#aabbcc) with that color as a background
			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})
end)

safely("later", function()
	require("mini.indentscope").setup()
end)

safely("later", function()
	require("mini.input").setup()
end)

safely("later", function()
	require("mini.jump").setup()
end)

safely("later", function()
	require("mini.jump2d").setup()
end)

safely("later", function()
	require("mini.keymap").setup()
	-- Navigate 'mini.completion' menu with `<Tab>` /  `<S-Tab>`
	MiniKeymap.map_multistep(
		"i",
		"<Tab>",
		{ "pmenu_next", "minisnippets_next", "minisnippets_expand", "jump_after_close" }
	)
	MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev", "minisnippets_prev", "jump_before_open" })

	MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev" })
	-- On `<CR>` try to accept current completion item, fall back to accounting
	-- for pairs from 'mini.pairs'
	MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
	-- On `<BS>` just try to account for pairs from 'mini.pairs'
	MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })
end)

safely("later", function()
	local map = require("mini.map")
	map.setup({
		-- Use Braille dots to encode text
		symbols = { encode = map.gen_encode_symbols.dot("4x2") },
		-- Show built-in search matches, 'mini.diff' hunks, and diagnostic entries
		integrations = {
			map.gen_integration.builtin_search(),
			map.gen_integration.diff(),
			map.gen_integration.diagnostic(),
		},
	})

	-- Map built-in navigation characters to force map refresh
	for _, key in ipairs({ "n", "N", "*", "#" }) do
		local rhs = key
			-- Also open enough folds when jumping to the next match
			.. "zv"
			.. "<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
		vim.keymap.set("n", key, rhs)
	end
end)

safely(when_args, function()
	-- Customize post-processing of LSP responses for a better user experience.
	-- Don't show 'Text' suggestions (usually noisy) and show snippets last.
	local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
	local process_items = function(items, base)
		return MiniCompletion.default_process_items(items, base, process_items_opts)
	end
	require("mini.completion").setup({
		lsp_completion = {
			-- Without this config autocompletion is set up through `:h 'completefunc'`.
			-- Although not needed, setting up through `:h 'omnifunc'` is cleaner
			-- (sets up only when needed) and makes it possible to use `<C-u>`.
			source_func = "omnifunc",
			auto_setup = false,
			process_items = process_items,
		},
	})

	-- Set 'omnifunc' for LSP completion only when needed.
	local on_attach = function(ev)
		vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
	end
	Config.new_autocmd("LspAttach", nil, on_attach, "Set 'omnifunc'")

	-- Advertise to servers that Neovim now supports certain set of completion and
	-- signature features through 'mini.completion'.
	vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
end)
safely("later", function()
	require("mini.move").setup()
end)

safely("later", function()
	require("mini.operators").setup()

	-- Create mappings for swapping adjacent arguments. Notes:
	-- - Relies on `a` argument textobject from 'mini.ai'.
	-- - It is not 100% reliable, but mostly works.
	-- - It overrides `:h (` and `:h )`.
	-- Explanation: `gx`-`ia`-`gx`-`ila` <=> exchange current and last argument
	-- Usage: when on `a` in `(aa, bb)` press `)` followed by `(`.
	vim.keymap.set("n", "(", "gxiagxila", { remap = true, desc = "Swap arg left" })
	vim.keymap.set("n", ")", "gxiagxina", { remap = true, desc = "Swap arg right" })
end)

safely("later", function()
	-- Create pairs not only in Insert, but also in Command line mode
	require("mini.pairs").setup({ modes = { command = true } })
end)

safely("later", function()
	-- Define language patterns to work better with 'friendly-snippets'
	local latex_patterns = { "latex/**/*.json", "**/latex.json" }
	local lang_patterns = {
		tex = latex_patterns,
		plaintex = latex_patterns,
		-- Recognize special injected language of markdown tree-sitter parser
		markdown_inline = { "markdown.json" },
	}

	local snippets = require("mini.snippets")
	local config_path = vim.fn.stdpath("config")
	snippets.setup({
		snippets = {
			-- Always load 'snippets/global.json' from config directory
			snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
			-- Load from 'snippets/' directory of plugins, like 'friendly-snippets'
			snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
		},
	})

	-- By default snippets available at cursor are not shown as candidates in
	-- 'mini.completion' menu. This requires a dedicated in-process LSP server
	-- that will provide them. To have that, uncomment next line (use `gcc`).
	-- MiniSnippets.start_lsp_server()
end)

safely("later", function()
	require("mini.splitjoin").setup()
end)

safely("later", function()
	require("mini.surround").setup()
end)

safely("later", function()
	require("mini.trailspace").setup()
end)

safely("later", function()
	require("mini.visits").setup()
end)

safely("now", function()
  vim.pack.add({ gh 'MagicDuck/grug-far.nvim' })
  require('grug-far').setup({})

  nmap_leader('fR', '<Cmd>lua require("grug-far").open()<Cr>', 'Replace')
  
end)
