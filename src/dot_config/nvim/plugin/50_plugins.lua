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
      force = false,
    },
    events = {
      on_open = {
        override = function(bufnr)
          vim.notify(icon("diagnostics.hint") .. " Opened chezmoi managed file")
        end
      },
      on_apply = {
        override = function(bufnr)
          vim.notify(icon('diagnostics.hint') .. ' Applied chezmoi file')
        end
      },
      on_watch = {
        override = function (bufnr)
          vim.notify(icon('diagnostics.hint') .. ' This file will be automatically applied')
        end
      }
    }
  })

	autocommand({ "BufRead", "BufNewFile" }, { os.getenv("HOME") .. "/.local/share/chezmoi/*" }, function(ev)
		local bufnr = ev.buf
		local edit_watch = function()
			require("chezmoi.commands.__edit").watch(bufnr)
		end
		vim.schedule(edit_watch)
	end)
end)

later(function()
	vim.pack.add({ gh("akinsho/toggleterm.nvim") })

	require("toggleterm").setup()

	-- Lazygit terminal
	local Terminal = require("toggleterm.terminal").Terminal
	local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })

	function _lazygit_toggle()
		lazygit:toggle()
	end

	nmap_leader("gg", "<Cmd>lua _lazygit_toggle()<CR>", icon("git") .. " LazyGit")
end)

-- later(function ()
--   vim.pack.add({ gh 'Olical/conjure' })
-- end)
