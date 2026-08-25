local global_tsserver = vim.fn.expand("~/.local/share/mise/installs/npm-typescript/5/lib/node_modules/typescript/lib/tsserver.js")

return {
	before_init = function(_, config)
		local local_tsserver = config.root_dir .. "/node_modules/typescript/lib/tsserver.js"
		if not vim.uv.fs_stat(local_tsserver) then
			config.init_options.tsserver = { path = global_tsserver }
		end
	end,
}
