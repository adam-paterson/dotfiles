now, later, gh, autocommand, nmap_leader, icon =
	Config.now, Config.later, Config.gh, Config.new_autocmd, Config.nmap_leader, Config.icon

later(function()
	vim.pack.add({ gh("olimorris/codecompanion.nvim") })

	require("codecompanion").setup({})
end)

now(function()
	vim.pack.add({ gh("nvim-lua/plenary.nvim"), gh("xvzc/chezmoi.nvim") })

	require("chezmoi").setup({
		edit = {
			watch = true,
			force = true,
		},
		events = {
			on_open = {
				override = function(bufnr)
					vim.notify(icon("diagnostics.hint") .. " Opened chezmoi managed file")
				end,
			},
			on_apply = {
				override = function(bufnr)
					vim.notify(icon("diagnostics.hint") .. " Applied chezmoi file")
				end,
			},
			on_watch = {
				override = function(bufnr)
					vim.notify(icon("diagnostics.hint") .. " This file will be automatically applied")
				end,
			},
		},
	})
end)

later(function()
	vim.pack.add({ gh("akinsho/toggleterm.nvim") })

	require("toggleterm").setup()

	-- Custom Terminals
	local Terminal = require("toggleterm.terminal").Terminal
	local Lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })

	function _lazygit_toggle()
		Lazygit:toggle()
	end

	nmap_leader("gg", "<Cmd>lua _lazygit_toggle()<CR>", icon("git") .. " LazyGit")

  local Glow = nil
  function _glow_markdown_preview()
    if Glow and Glow:is_open() then
      Glow:close()
      return
    end
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or vim.bo.filetype ~= "markdown" then
      vim.notify("Markdown preview: not a markdown buffer", vim.log.levels.WARN)
      return
    end
    if Glow then Glow:shutdown() end
    Glow = Terminal:new({
      cmd = "glow " .. vim.fn.shellescape(file),
      direction = "vertical",
      close_on_exit = false,
      display_name = "markdown",
      on_open = function(term)
        vim.cmd("stopinsert")
        vim.api.nvim_set_option_value("winbar", "", { win = term.window })
      end,
    })
    Glow:open(math.floor(vim.o.columns * 0.4))
  end

  nmap_leader("om", "<Cmd>lua _glow_markdown_preview()<Cr>", "Markdown Preview")
end)


later(function()
	vim.pack.add({ gh("sindrets/diffview.nvim") })

	local actions = require("diffview.actions")

	require("diffview").setup({
		enhanced_diff_hl = true,
		show_help_hints = true,
		view = {
			default = { winbar_info = false },
			merge_tool = {
				layout = "diff3_mixed",
				disable_diagnostics = true,
				winbar_info = true,
			},
			file_history = { winbar_info = false },
		},
		file_panel = {
			listing_style = "tree",
			tree_options = {
				flatten_dirs = true,
				folder_statuses = "only_folded",
			},
			win_config = {
				position = "left",
				width = 35,
			},
		},
		keymaps = {
			view = {
				-- Preserve the global explorer and buffer key groups.
				{ "n", "<leader>e", false },
				{ "n", "<leader>b", false },
				{ "n", "<tab>", actions.select_next_entry, { desc = "Next file" } },
				{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Prev file" } },
				{ "n", "<leader>gf", actions.toggle_files, { desc = "Toggle file panel" } },
				{ "n", "<leader>gF", actions.focus_files, { desc = "Focus file panel" } },
				{ "n", "q", actions.close, { desc = "Close diffview" } },
			},
			file_panel = {
				{ "n", "<leader>e", false },
				{ "n", "<leader>b", false },
				{ "n", "<leader>gF", actions.focus_files, { desc = "Focus file panel" } },
				{ "n", "j", actions.next_entry, { desc = "Next entry" } },
				{ "n", "k", actions.prev_entry, { desc = "Prev entry" } },
				{ "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
				{ "n", "s", actions.toggle_stage_entry, { desc = "Stage/unstage" } },
				{ "n", "S", actions.stage_all, { desc = "Stage all" } },
				{ "n", "U", actions.unstage_all, { desc = "Unstage all" } },
				{ "n", "X", actions.restore_entry, { desc = "Restore entry" } },
				{ "n", "R", actions.refresh_files, { desc = "Refresh" } },
				{ "n", "<tab>", actions.select_next_entry, { desc = "Next file" } },
				{ "n", "<s-tab>", actions.select_prev_entry, { desc = "Prev file" } },
				{ "n", "<leader>gf", actions.toggle_files, { desc = "Toggle file panel" } },
				{ "n", "q", actions.close, { desc = "Close diffview" } },
			},
			file_history_panel = {
				{ "n", "<leader>e", false },
				{ "n", "<leader>b", false },
				{ "n", "<leader>gf", actions.toggle_files, { desc = "Toggle file panel" } },
				{ "n", "<leader>gF", actions.focus_files, { desc = "Focus file panel" } },
				{ "n", "j", actions.next_entry, { desc = "Next entry" } },
				{ "n", "k", actions.prev_entry, { desc = "Prev entry" } },
				{ "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
				{ "n", "y", actions.copy_hash, { desc = "Copy commit hash" } },
				{ "n", "q", actions.close, { desc = "Close diffview" } },
			},
		},
	})
end)
