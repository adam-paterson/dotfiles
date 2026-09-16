-- Shared by nvim -d, :diffsplit, and merge tools that use native diff mode.
Config.is_native_diff = function()
	local diffview = package.loaded["diffview.lib"]
	return vim.wo.diff and not (diffview and diffview.get_current_view())
end

local function diff_windows()
	local windows = vim.tbl_filter(function(win)
		return vim.wo[win].diff
	end, vim.api.nvim_tabpage_list_wins(0))
	table.sort(windows, function(a, b)
		return vim.fn.win_id2win(a) < vim.fn.win_id2win(b)
	end)
	return windows
end

local function choose_panel(index, obtain)
	if not Config.is_native_diff() then
		vim.notify("Use diff-panel shortcuts from a diff window", vim.log.levels.WARN)
		return
	end
	local windows = diff_windows()
	local win = windows[index == -1 and #windows or index]
	if not win then
		vim.notify("That diff panel is not open", vim.log.levels.WARN)
		return
	end
	if obtain then
		if win == vim.api.nvim_get_current_win() then
			vim.notify("Choose a different panel to take a hunk from", vim.log.levels.WARN)
			return
		end
		vim.cmd.diffget(tostring(vim.api.nvim_win_get_buf(win)))
	else
		vim.api.nvim_set_current_win(win)
	end
end

local mappings = {
	{
		"l",
		function()
			choose_panel(1, true)
		end,
		"Take hunk from first diff panel",
	},
	{
		"r",
		function()
			choose_panel(-1, true)
		end,
		"Take hunk from last diff panel",
	},
	{ "n", "]c", "Next diff hunk" },
	{ "p", "[c", "Previous diff hunk" },
}
for i = 1, 4 do
	table.insert(mappings, {
		tostring(i),
		function()
			choose_panel(i, false)
		end,
		"Focus diff panel " .. i,
	})
	table.insert(mappings, {
		"g" .. i,
		function()
			choose_panel(i, true)
		end,
		"Take hunk from diff panel " .. i,
	})
end

-- Diff is window-local: even the same buffer can be open outside a diff.
local mapped_buffer
local function sync_mappings()
	if mapped_buffer and vim.api.nvim_buf_is_valid(mapped_buffer) then
		for _, map in ipairs(mappings) do
			vim.keymap.del("n", "<leader>gm" .. map[1], { buffer = mapped_buffer })
		end
	end
	mapped_buffer = nil
	if Config.is_native_diff() then
		mapped_buffer = vim.api.nvim_get_current_buf()
		for _, map in ipairs(mappings) do
			vim.keymap.set("n", "<leader>gm" .. map[1], map[2], { buffer = mapped_buffer, desc = map[3] })
		end
	end
end

local function label_panels()
	local windows = diff_windows()
	-- Diffview owns its layout and version labels.
	for _, win in ipairs(windows) do
		if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match("^diffview://") then
			return
		end
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.wo[win].winbar:match("^ Diff panel ") then
			vim.wo[win].winbar = ""
		end
	end
	for i, win in ipairs(windows) do
		if vim.wo[win].winbar == "" then
			vim.wo[win].winbar = " Diff panel " .. i .. " — %f"
		end
	end
end
local function refresh()
	sync_mappings()
	vim.schedule(function()
		sync_mappings()
		label_panels()
	end)
end
local group = vim.api.nvim_create_augroup("native-diff", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
	group = group,
	callback = refresh,
})
vim.api.nvim_create_autocmd("OptionSet", {
	group = group,
	pattern = "diff",
	callback = refresh,
})
