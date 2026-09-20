vim.keymap.set("n", "<Leader>lm", "<Cmd>Markview toggle<CR>", { buffer = true, desc = "Markdown preview toggle" })
vim.keymap.set("n", "<Leader>lM", "<Cmd>Markview splitToggle<CR>", { buffer = true, desc = "Markdown split preview toggle" })
vim.keymap.set("n", "<Leader>lH", "<Cmd>Markview HybridToggle<CR>", { buffer = true, desc = "Markdown hybrid mode toggle (global)" })

vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
	.. 'silent! execute "nunmap <buffer> <Leader>lm" | silent! execute "nunmap <buffer> <Leader>lM" | silent! execute "nunmap <buffer> <Leader>lH"'
