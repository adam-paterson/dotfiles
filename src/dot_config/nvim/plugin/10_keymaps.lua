-- ═══════════════════════════════════════════════════════════
-- KEYMAP CONFIGURATION
-- This file contains definitions of custom general
-- and Leader mappings.
-- ═══════════════════════════════════════════════════════════
local icons, icon, nmap, imap_expr, nmap_leader, xmap_leader, tmap_leader =
	Config.icons, Config.icon, Config.nmap, Config.imap_expr, Config.nmap_leader, Config.xmap_leader, Config.tmap_leader

-- An example helper to create a Normal mode mapping

-- ─ General ─────────────────────────────────────────────────
imap_expr("<Tab>", [[pumvisible() ? "\<C-n>" : "\<Tab>"]])
imap_expr("<S-Tab>", [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]])

-- ─ Leader Mappings ─────────────────────────────────────────

-- Create a global table with information about Leader groups in certain modes.
-- This is used to provide 'mini.clue' with extra clues.
-- Add an entry if you create a new group.
Config.leader_group_clues = {
	{ mode = "n", keys = "<Leader>b", desc = icon("buffer") .. " Buffer" },
	function()
		if not vim.wo.diff then
			return {}
		end
		return {
			{ mode = "n", keys = "<Leader>gm", desc = icon("diff") .. " Merge/Diff" },
			{ mode = "n", keys = "<Leader>gmg", desc = "Take hunk from panel" },
		}
	end,
	{ mode = "n", keys = "<Leader>e", desc = icon("explore") .. " Explore/Edit" },
	{ mode = "n", keys = "<Leader>f", desc = icon("search") .. " Find" },
	{ mode = "n", keys = "<Leader>g", desc = icon("git") .. " Git" },
	{ mode = "n", keys = "<Leader>l", desc = icon("code") .. " Language" },
	{ mode = "n", keys = "<Leader>m", desc = icon("map") .. " Map" },
	{ mode = "n", keys = "<Leader>o", desc = icon("other") .. " Other" },
	{ mode = "n", keys = "<Leader>s", desc = icon("save") .. " Session" },
	{ mode = "n", keys = "<Leader>t", desc = icon("terminal") .. " Terminal" },
	{ mode = "n", keys = "<Leader>v", desc = icon("eye") .. " Visits" },

	{ mode = "x", keys = "<Leader>g", desc = icon("git") .. " Git" },
	{ mode = "x", keys = "<Leader>l", desc = icon("code") .. " Language" },
}

-- ─ [b] Buffer ─────────────────────────────────────────────
local new_scratch_buffer = function()
	vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader("ba", "<Cmd>b#<CR>", icon("alternate") .. " Alternate")
nmap_leader("bd", "<Cmd>lua MiniBufremove.delete()<CR>", icon("delete") .. " Delete")
nmap_leader("bD", "<Cmd>lua MiniBufremove.delete(0, true)<CR>", icon("delete") .. " Delete!")
nmap_leader("bs", new_scratch_buffer, icon("file") .. " Scratch")
nmap_leader("bw", "<Cmd>lua MiniBufremove.wipeout()<CR>", icon("wipeout") .. " Wipeout")
nmap_leader("bW", "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>", icon("wipeout") .. " Wipeout!")

-- ─ [e] Explorer ─────────────────────────────────────────────
-- Toggle explorer; opens anchored at current file (like nvim-tree)
local explore_at_file = function()
	local path = vim.api.nvim_buf_get_name(0)
	if not MiniFiles.close() then MiniFiles.open(path ~= "" and path or nil) end
end
local explore_quickfix = function()
	vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end
local explore_locations = function()
	vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end

nmap_leader("ee", explore_at_file, icon("explore") .. " File Explorer")
nmap_leader("eE", "<Cmd>lua MiniFiles.open()<CR>", icon("explore") .. " File Explorer (Root)")
nmap_leader("et", "<Cmd>NvimTreeToggle<CR>", icon("explore") .. " File Tree (toggle)")
nmap_leader("en", "<Cmd>lua MiniNotify.show_history()<CR>", icon("chat") .. " Notifications")
nmap_leader("eq", explore_quickfix, icon("quick") .. " Quickfix list")
nmap_leader("el", explore_locations, icon("map") .. " Location list")

-- ─ [f] Find ─────────────────────────────────────────────

local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'

nmap_leader("f/", '<Cmd>Pick history scope="/"<CR>', icon("history") .. ' "/" history')
nmap_leader("f:", '<Cmd>Pick history scope=":"<CR>', icon("history") .. ' ":" history')
nmap_leader("fa", '<Cmd>Pick git_hunks scope="staged"<CR>', icon("git") .. " Added hunks (all)")
nmap_leader("fA", pick_added_hunks_buf, icon("git") .. " Added hunks (buf)")
nmap_leader("fb", "<Cmd>Pick buffers<CR>", icon("buffer") .. " Buffers")
nmap_leader("fc", "<Cmd>Pick git_commits<CR>", icon("git") .. " Commits (all)")
nmap_leader("fC", '<Cmd>Pick git_commits path="%"<CR>', icon("git") .. " Commits (buf)")
nmap_leader("fd", '<Cmd>Pick diagnostic scope="all"<CR>', icon("diagnostic") .. " Diagnostic workspace")
nmap_leader("fD", '<Cmd>Pick diagnostic scope="current"<CR>', icon("diagnostic") .. " Diagnostic buffer")
nmap_leader("ff", "<Cmd>Pick files<CR>", icon("file") .. " Files")
nmap_leader("fg", "<Cmd>Pick grep_live<CR>", icon("search") .. " Grep live")
nmap_leader("fG", '<Cmd>Pick grep pattern="<cword>"<CR>', icon("search") .. " Grep current word")
nmap_leader("fh", "<Cmd>Pick help<CR>", icon("help") .. " Help tags")
nmap_leader("fH", "<Cmd>Pick hl_groups<CR>", icon("paint") .. " Highlight groups")
nmap_leader("fl", '<Cmd>Pick buf_lines scope="all"<CR>', icon("list") .. " Lines (all)")
nmap_leader("fL", '<Cmd>Pick buf_lines scope="current"<CR>', icon("list") .. " Lines (buf)")
nmap_leader("fm", "<Cmd>Pick git_hunks<CR>", icon("git") .. " Modified hunks (all)")
nmap_leader("fM", '<Cmd>Pick git_hunks path="%"<CR>', icon("git") .. " Modified hunks (buf)")
nmap_leader("fr", "<Cmd>Pick resume<CR>", icon("resume") .. " Resume")
nmap_leader("fs", pick_workspace_symbols_live, icon("tag") .. " Symbols workspace (live)")
nmap_leader("fS", '<Cmd>Pick lsp scope="document_symbol"<CR>', icon("tag") .. " Symbols document")
nmap_leader("fv", '<Cmd>Pick visit_paths cwd=""<CR>', icon("eye") .. " Visit paths (all)")
nmap_leader("fV", "<Cmd>Pick visit_paths<CR>", icon("eye") .. " Visit paths (cwd)")

-- ─ [g] Git ─────────────────────────────────────────────
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. " --follow -- %"

nmap_leader("ga", "<Cmd>Git diff --cached<CR>", icon("diff") .. " Added diff")
nmap_leader("gA", "<Cmd>Git diff --cached -- %<CR>", icon("diff") .. " Added diff buffer")
nmap_leader("gc", "<Cmd>Git commit<CR>", icon("commit") .. " Commit")
nmap_leader("gC", "<Cmd>Git commit --amend<CR>", icon("commit") .. " Commit amend")
nmap_leader("gd", "<Cmd>Git diff<CR>", icon("diff") .. " Diff")
nmap_leader("gD", "<Cmd>Git diff -- %<CR>", icon("diff") .. " Diff buffer")
nmap_leader("gl", "<Cmd>" .. git_log_cmd .. "<CR>", icon("history") .. " Log")
nmap_leader("gL", "<Cmd>" .. git_log_buf_cmd .. "<CR>", icon("history") .. " Log buffer")
nmap_leader("go", "<Cmd>lua MiniDiff.toggle_overlay()<CR>", icon("toggle") .. " Toggle overlay")
nmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", icon("eye") .. " Show at cursor")

xmap_leader("gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", icon("eye") .. " Show at selection")

-- ─ [l] Languages ─────────────────────────────────────────────
-- Share the Insert-mode completion prefix so mini.clue exposes inspection too.
vim.keymap.set("i", "<C-x>h", vim.lsp.buf.hover, { desc = "Hover: symbol type and docs" })
vim.keymap.set("i", "<C-x>a", vim.lsp.buf.signature_help, { desc = "Argument hints (signature help)" })

nmap_leader("la", "<Cmd>lua vim.lsp.buf.code_action()<CR>", icon("action") .. " Actions")
nmap_leader("ld", "<Cmd>lua vim.diagnostic.open_float()<CR>", icon("diagnostic") .. " Diagnostic")
nmap_leader("lf", '<Cmd>lua require("conform").format()<CR>', icon("format") .. " Format")
nmap_leader("lh", "<Cmd>lua vim.lsp.buf.hover()<CR>", icon("hover") .. " Hover")

nmap_leader("li", '<Cmd>Pick lsp scope="implementation"<CR>', icon("gears") .. " Implementations")
nmap_leader("lr", "<Cmd>lua vim.lsp.buf.rename()<CR>", icon("rename") .. " Rename")
nmap_leader("lR", '<Cmd>Pick lsp scope="references"<CR>', icon("link") .. " References")
nmap_leader("ls", "<Cmd>lua vim.lsp.buf.definition()<CR>", icon("source") .. " Definition")
nmap_leader("lt", '<Cmd>Pick lsp scope="type_definition"<CR>', icon("type") .. " Type definition")

nmap_leader("lS", '<Cmd>Pick lsp scope="document_symbol"<CR>', icon("tag") .. " Symbols document")
nmap_leader("lw", '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>', icon("tag") .. " Symbols workspace")

nmap_leader("ll", "<Cmd>lua vim.lsp.codelens.run()<CR>", icon("lens") .. " Run CodeLens")

xmap_leader("lf", '<Cmd>lua require("conform").format()<CR>', icon("format") .. " Format selection")

-- m is for 'Map'. Common usage:
-- - `<Leader>mt` - toggle map from 'mini.map' (closed by default)
-- - `<Leader>mf` - focus on the map for fast navigation
-- - `<Leader>ms` - change map's side (if it covers something underneath)
nmap_leader("mf", "<Cmd>lua MiniMap.toggle_focus()<CR>", icon("focus") .. " Focus (toggle)")
nmap_leader("mr", "<Cmd>lua MiniMap.refresh()<CR>", icon("refresh") .. " Refresh")
nmap_leader("ms", "<Cmd>lua MiniMap.toggle_side()<CR>", icon("toggle") .. " Side (toggle)")
nmap_leader("mt", "<Cmd>lua MiniMap.toggle()<CR>", icon("toggle") .. " Toggle")

-- o is for 'Other'. Common usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
nmap_leader("or", "<Cmd>lua MiniMisc.resize_window()<CR>", icon("resize") .. " Resize to default width")
nmap_leader("ot", "<Cmd>lua MiniTrailspace.trim()<CR>", icon("trim") .. " Trim trailspace")
nmap_leader("oz", "<Cmd>lua MiniMisc.zoom()<CR>", icon("zoom") .. " Zoom toggle")
nmap_leader("oc", '<Cmd>lua require("chezmoi.pick").mini()<CR>', icon("other") .. " Chezmoi pick")

-- s is for 'Session'. Common usage:
-- - `<Leader>sn` - start new session
-- - `<Leader>sr` - read previously started session
-- - `<Leader>sR` - restart Neovim preserving current session
local session_new = 'vim.ui.input({ prompt = "Session name: " }, MiniSessions.write)'

nmap_leader("sd", '<Cmd>lua MiniSessions.select("delete")<CR>', icon("delete") .. " Delete")
nmap_leader("sn", "<Cmd>lua " .. session_new .. "<CR>", icon("new") .. " New")
nmap_leader("sr", '<Cmd>lua MiniSessions.select("read")<CR>', icon("play") .. " Read")
nmap_leader("sR", "<Cmd>lua MiniSessions.restart()<CR>", icon("refresh") .. " Restart")
nmap_leader("sw", "<Cmd>lua MiniSessions.write()<CR>", icon("save") .. " Write current")

-- t is for 'Terminal'
nmap_leader("tT", "<Cmd>horizontal term<CR>", icon("terminal") .. " Terminal (horizontal)")
nmap_leader("tt", "<Cmd>vertical term<CR>", icon("terminal") .. " Terminal (vertical)")

-- v is for 'Visits'. Common usage:
-- - `<Leader>vv` - add    "core" label to current file.
-- - `<Leader>vV` - remove "core" label to current file.
-- - `<Leader>vc` - pick among all files with "core" label.
local make_pick_core = function(cwd, desc)
	return function()
		local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
		local local_opts = { cwd = cwd, filter = "core", sort = sort_latest }
		MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
	end
end

nmap_leader("vc", make_pick_core("", "Core visits (all)"), icon("star") .. " Core visits (all)")
nmap_leader("vC", make_pick_core(nil, "Core visits (cwd)"), icon("star") .. " Core visits (cwd)")
nmap_leader("vv", '<Cmd>lua MiniVisits.add_label("core")<CR>', icon("star") .. ' Add "core" label')
nmap_leader("vV", '<Cmd>lua MiniVisits.remove_label("core")<CR>', icon("star_o") .. ' Remove "core" label')
nmap_leader("vl", "<Cmd>lua MiniVisits.add_label()<CR>", icon("tag") .. " Add label")
nmap_leader("vL", "<Cmd>lua MiniVisits.remove_label()<CR>", icon("tag") .. " Remove label")

-- q is for 'Quit'
nmap("q", "<cmd>qa<CR>", icon("exit") .. " Quit")

-- ─ Terminal ────────────────────────────────────────────────
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Focus on left window" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

xmap_leader('a', function ()
  vim.cmd('normal! "+y')
  vim.fn.jobstart({
    "herdr",
    "plugin",
    "action",
    "invoke",
    "annotate.capture"
  })
end, "Annotate in herdr")

-- stylua: ignore end
