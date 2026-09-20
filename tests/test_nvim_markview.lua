-- Run from the repo root: nvim --headless -u NONE -l tests/test_nvim_markview.lua
vim.opt.runtimepath:append(vim.fn.getcwd() .. "/src/dot_config/nvim/after")
vim.g.mapleader = " "
vim.cmd("filetype plugin on")

local commands = { lm = "toggle", lM = "splitToggle", lH = "HybridToggle" }
local invoked
vim.api.nvim_create_user_command("Markview", function(opts) invoked = opts.args end, { nargs = 1 })
local function check_markdown()
	for key, command in pairs(commands) do
		local mapping = vim.fn.maparg(" " .. key, "n", false, true)
		assert(mapping.buffer == 1, key .. " must be buffer-local")
		vim.cmd.normal({ args = { " " .. key }, bang = false })
		assert(invoked == command, key .. " invoked the wrong command")
	end
end
local function check_absent()
	for key in pairs(commands) do
		assert(vim.tbl_isempty(vim.fn.maparg(" " .. key, "n", false, true)), key .. " leaked outside Markdown")
	end
end

vim.cmd("setfiletype markdown")
local markdown_buffer = vim.api.nvim_get_current_buf()
check_markdown()
vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(true, false))
vim.cmd("setfiletype lua")
check_absent()
vim.api.nvim_set_current_buf(markdown_buffer)
check_markdown()
vim.bo.filetype = "text"
check_absent()
vim.bo.filetype = "markdown"
check_markdown()
print("PASS: Markdown-local mappings, command dispatch, buffer switching, and filetype cleanup")
