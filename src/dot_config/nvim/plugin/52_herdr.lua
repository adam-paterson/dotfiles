local safely = require("mini.misc").safely
local xmap_leader = Config.xmap_leader

safely("later", function()
	local HerdrAnnotate = function()
		-- Hand the selection to the plugin through a file: works on headless servers too.
		vim.cmd('normal! "zy')

		local base = os.getenv("XDG_RUNTIME_DIR")
		if not base or base == "" then
			base = vim.fn.fnamemodify(vim.fn.tempname(), ":h")
		end

		local session = os.getenv("HERDR_SESSION")

		if not session then
			session = ""
		end

		local dir = base .. "/herdr-annotate-" .. vim.loop.getuid()
		vim.fn.mkdir(dir, "p", "0700")
		vim.fn.writefile(vim.split(vim.fn.getreg("z"), "\n"), dir .. "/selection")
		vim.fn.jobstart({ "herdr", "plugin", "action", "invoke", "annotate.capture", "--session", session })
	end

	xmap_leader("a", HerdrAnnotate, "Herder: Annotate")
end)
