-- Define global config table to pass data between scripts
-- Global variable accessed with `_G.Config` and `Config`
_G.Config = {}

-- Custom autocommand group and helper to create an autocommand.
local gr = vim.api.nvim_create_augroup("custom-config", {})
Config.new_autocmd = function(event, pattern, callback, desc)
	local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
	vim.api.nvim_create_autocmd(event, opts)
end

-- Custom `vim.pack.add()` hook helper. For plugins which require
-- hooks.
Config.on_packchanged = function(plugin_name, kinds, callback, desc)
	local f = function(event)
		local name, kind = event.data.spec.name, event.data.kind
		if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
			return
		end
		if not event.data.active then
			vim.cmd.packadd(plugin_name)
		end
		callback(event.data)
	end
	Config.new_autocmd("PackChanged", "*", f, desc)
end

-- Most plugins will come from GitHub. This helper means we don't have
-- to type it every time.
Config.gh = function(repo)
	return "https://github.com/" .. repo
end

-- `mini.nvim` has some of the cleanest default modules. We'll be using
-- most of them.
vim.pack.add({ Config.gh("nvim-mini/mini.nvim") })

-- Keymap helpers

Config.nmap = function(lhs, rhs, desc)
	-- See `:h vim.keymap.set()`
	vim.keymap.set("n", lhs, rhs, { desc = desc })
end
Config.imap_expr = function(lhs, rhs)
	vim.keymap.set("i", lhs, rhs, { expr = true })
end
Config.nmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end
Config.xmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("x", "<Leader>" .. suffix, rhs, { desc = desc })
end
Config.tmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("v", "<Leader>" .. suffix, rhs, { desc = desc })
end

-- I hate this here, but it'll do for now
-- this is for all other icons I cannot grab or re-use from MiniIcons
Config.icons = {
	diagnostics = {
		warn = "",
		error = "",
		info = "",
		hint = "",
	},
	buffer = "\u{f0c5}",
	explore = "",
	search = "󰍉",
	git = "",
	map = "",
	terminal = "",
	save = "",
	code = "",
	other = "",
	eye = "",
	chat = "󰻞",
	alternate = "\u{f0ec}", -- nf-fa-exchange
	delete = "\u{f014}", -- nf-fa-trash_o
	wipeout = "\u{f1f8}", -- nf-fa-trash
	file = "\u{f016}", -- nf-fa-file_o
	history = "\u{f1da}", -- nf-fa-history
	diagnostic = "\u{f0f1}", -- nf-fa-stethoscope
	help = "\u{f059}", -- nf-fa-question_circle
	paint = "\u{f1fc}", -- nf-fa-paint_brush
	list = "\u{f03a}", -- nf-fa-list
	resume = "\u{f01e}", -- nf-fa-repeat
	link = "\u{f0c1}", -- nf-fa-link
	tag = "\u{f02b}", -- nf-fa-tag
	hover = "\u{f25a}", -- nf-fa-hand_pointer_o
	format = "\u{f03c}", -- nf-fa-indent
	toggle = "\u{f205}", -- nf-fa-toggle_on
	diff = "\u{f0db}", -- nf-fa-columns
	commit = "\u{f00c}", -- nf-fa-check
	action = "\u{f0e7}", -- nf-fa-bolt
	gears = "\u{f085}", -- nf-fa-gears
	source = "\u{f1c9}", -- nf-fa-file_code_o
	type = "\u{f031}", -- nf-fa-font
	lens = "\u{f00e}", -- nf-fa-search_plus
	rename = "\u{f040}", -- nf-fa-pencil
	focus = "\u{f05b}", -- nf-fa-crosshairs
	refresh = "\u{f021}", -- nf-fa-refresh
	resize = "\u{f07e}", -- nf-fa-arrows_h
	trim = "\u{f0c4}", -- nf-fa-scissors
	zoom = "\u{f065}", -- nf-fa-expand
	new = "\u{f067}", -- nf-fa-plus
	play = "\u{f04b}", -- nf-fa-play
	star = "\u{f005}", -- nf-fa-star
	star_o = "\u{f006}", -- nf-fa-star_o
	quick = "󰅒",
	exit = "󰩈",
}

Config.icon = function(path)
	local t = Config.icons
	for k in path:gmatch("[^.]+") do
		t = t[k]
	end
	return t
end
