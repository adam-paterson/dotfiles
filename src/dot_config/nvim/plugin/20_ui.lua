-- ═══════════════════════════════════════════════════════════
-- USER INTERFACE
-- General user interface plugins and configuration
-- ═══════════════════════════════════════════════════════════

local safely = require("mini.misc").safely
local gh, nmap_leader = Config.gh, Config.nmap_leader

-- ─ Colorscheme ─────────────────────────────────────────────
safely("now", function()
	-- vim.pack.add({ gh("rebelot/kanagawa.nvim") })
	-- vim.cmd("colorscheme kanagawa-wave")

  vim.pack.add({gh "catppuccin/nvim"})
  vim.cmd("colorscheme catppuccin-nvim")
end)

-- ─ Statusline ──────────────────────────────────────────────
safely("later", function()
	vim.pack.add({ gh("nvim-lualine/lualine.nvim") })
end)

-- ─ Dashboard / Starter ─────────────────────────────────────
safely("now", function()
	require("mini.starter").setup({
		header = "Hello",
		footer = "Bum",
	})
end)

-- ─ File explorers ─────────────────────────────────────
safely("now", function()
	require("mini.files").setup({
    windows = {
      preview = true,
      width_focus = 35,
    },
		mappings = {
			synchronize = "<C-s>",
		},
	})
end)

safely("later", function()
	vim.pack.add({ gh("nvim-tree/nvim-tree.lua") })
	-- Keep mini.files in charge of opening directories; the tree is opt-in.
	require("nvim-tree").setup({
		disable_netrw = false,
		hijack_netrw = false,
		hijack_directories = { enable = false },
		on_attach = function(bufnr)
			local api = require("nvim-tree.api")
			api.config.mappings.default_on_attach(bufnr)
			vim.keymap.set("n", "h", api.node.navigate.parent_close, { buffer = bufnr, desc = "Close directory / parent" })
			vim.keymap.set("n", "l", api.node.open.edit, { buffer = bufnr, desc = "Expand directory / open file" })
		end,
	})
end)

safely("now", function()
  vim.pack.add({gh 'Bekaboo/dropbar.nvim' })

  -- Keep terminal splits (e.g. the glow preview) chrome-free:
  -- dropbar otherwise renders the `term://...` buffer name as a winbar.
  local default_enable = require("dropbar.configs").opts.bar.enable
  require("dropbar").setup({
    bar = {
      enable = function(buf, win, info)
        return vim.bo[buf].ft ~= "toggleterm" and default_enable(buf, win, info)
      end,
    },
  })

  local dropbar_api = require("dropbar.api")
  nmap_leader(";", dropbar_api.pick, "Pick a command from the dropbar")
  nmap_leader("[;", dropbar_api.goto_context_start, "Previous command from the dropbar")
  nmap_leader("];", dropbar_api.select_next_context, "Next command from the dropbar")
end)

-- ─ Key hints ─────────────────────────────────────────

safely("later", function()
	local miniclue = require("mini.clue")
  -- stylua: ignore
  miniclue.setup({
    -- Define which clues to show. By default shows only clues for custom mappings
    -- (uses `desc` field from the mapping; takes precedence over custom clue).
    clues = {
      -- This is defined in 'plugin/20_keymaps.lua' with Leader group descriptions
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      { mode = 'i', keys = '<C-x><C-o>', desc = 'LSP completion: properties / methods' },
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
	-- Keep Neovim's native multicursor command instead of mini.clue's macro mapping.
	vim.keymap.del("n", "Q")
end)

-- ─ Animations ─────────────────────────────────────────
safely("later", function()
	require("mini.animate").setup()
end)

safely("later", function()
	require("mini.cmdline").setup()
end)

safely("later", function()
	require("mini.pick").setup({
    window = {
      prompt_caret = "󰗧 ",
      prompt_prefix = "󰘧 "
    }
  })
end)

safely("now", function()
	require("mini.notify").setup()
end)
