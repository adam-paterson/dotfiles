-- ═══════════════════════════════════════════════════════════
-- USER INTERFACE
-- General user interface plugins and configuration
-- ═══════════════════════════════════════════════════════════

local now, now_if_args, later, gh, autocommand =
	Config.now, Config.now_if_args, Config.later, Config.gh, Config.new_autocmd

-- ─ Colorscheme ─────────────────────────────────────────────
now(function()
	vim.pack.add({ gh("rebelot/kanagawa.nvim") })
	vim.cmd("colorscheme kanagawa-wave")
end)

-- ─ Statusline ──────────────────────────────────────────────
later(function()
	vim.pack.add({ gh("nvim-lualine/lualine.nvim") })
	-- kanso ships a lualine theme; use it as the base and tweak what you need
	local theme = require("lualine.themes.kanagawa")
	require("lualine").setup({ options = { theme = theme } })
end)

-- ─ Dashboard / Starter ─────────────────────────────────────
now(function()
	require("mini.starter").setup({
		header = "Hello",
		footer = "Bum",
	})
end)

-- ─ File explorers ─────────────────────────────────────

now(function()
  vim.pack.add({ gh 'nvim-tree/nvim-tree.lua'})

  require('nvim-tree').setup()
end)

now(function()
	require("mini.files").setup({
		mappings = {
			synchronize = "<C-s>",
		},
	})
end)

-- ─ Key hints ─────────────────────────────────────────

later(function()
	local miniclue = require("mini.clue")
  -- stylua: ignore
  miniclue.setup({
    -- Define which clues to show. By default shows only clues for custom mappings
    -- (uses `desc` field from the mapping; takes precedence over custom clue).
    clues = {
      -- This is defined in 'plugin/20_keymaps.lua' with Leader group descriptions
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      -- This creates a submode for window resize mappings. Try the following:
      -- - Press `<C-w>s` to make a window split.
      -- - Press `<C-w>+` to increase height. Clue window still shows clues as if
      --   `<C-w>` is pressed again. Keep pressing just `+` to increase height.
      --   Try pressing `-` to decrease height.
      -- - Stop submode either by `<Esc>` or by any key that is not in submode.
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    -- Explicitly opt-in for set of common keys to trigger clue window
    triggers = {
      { mode = { 'n', 'x' }, keys = '<Leader>' }, -- Leader triggers
      { mode =   'n',        keys = '\\' },       -- mini.basics
      { mode = { 'n', 'x' }, keys = '[' },        -- mini.bracketed
      { mode = { 'n', 'x' }, keys = ']' },
      { mode =   'i',        keys = '<C-x>' },    -- Built-in completion
      { mode = { 'n', 'x' }, keys = 'g' },        -- `g` key
      { mode = { 'n', 'x' }, keys = "'" },        -- Marks
      { mode = { 'n', 'x' }, keys = '`' },
      { mode = { 'n', 'x' }, keys = '"' },        -- Registers
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode =   'n',        keys = '<C-w>' },    -- Window commands
      { mode = { 'n', 'x' }, keys = 's' },        -- `s` key (mini.surround, etc.)
      { mode = { 'n', 'x' }, keys = 'z' },        -- `z` key
    },
  })
end)

-- ─ Animations ─────────────────────────────────────────
later(function()
	require("mini.animate").setup()
end)

later(function()
	require("mini.cmdline").setup()
end)

later(function()
	require("mini.pick").setup()
end)

now(function()
	require("mini.notify").setup()
end)
