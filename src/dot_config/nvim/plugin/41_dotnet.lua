-- Register the clients globally; start them only for files in .NET projects.
vim.pack.add({ {
	src = Config.gh("seblyng/roslyn.nvim"),
	version = "bf1bd4e70bc7068d1b4aebf4ce03cc19a86615be",
} })

local function project_root(bufnr)
	return vim.fs.root(bufnr, function(name)
		return name:match("%.csproj$") or name:match("%.sln$") or name:match("%.slnx$")
	end)
end

-- Keep upstream solution selection, but disallow its selected-solution
-- fallback from attaching to unrelated standalone C#/Razor files.
local roslyn_root = vim.lsp.config.roslyn.root_dir
vim.lsp.config("roslyn", {
	cmd = {
		vim.fn.stdpath("config") .. "/tools/roslyn/roslyn-language-server",
		"--stdio",
	},
	root_dir = function(bufnr, on_dir)
		if vim.api.nvim_buf_get_name(bufnr):match("^roslyn%-source%-generated://") or project_root(bufnr) then
			roslyn_root(bufnr, on_dir)
		end
	end,
})

-- Only Razor's projected HTML buffers need this server. Ordinary HTML in
-- unrelated projects is intentionally unaffected.
vim.lsp.config("html", {
	root_dir = function(bufnr, on_dir)
		if not vim.api.nvim_buf_get_name(bufnr):match("__virtual%.html$") then
			return
		end
		local root = project_root(bufnr)
		if root then
			on_dir(root)
		end
	end,
})
vim.lsp.enable("html")
