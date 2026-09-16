-- Language adapters and project launch configurations are configured separately.
Config.later(function()
	vim.pack.add({
		Config.gh("mfussenegger/nvim-dap"),
		Config.gh("nvim-neotest/nvim-nio"),
		Config.gh("rcarriga/nvim-dap-ui"),
	})

	local dap, dapui = require("dap"), require("dapui")
	dapui.setup({})

	for name, sign in pairs({
		Breakpoint = { "", "DiagnosticError" },
		BreakpointCondition = { "", "DiagnosticWarn" },
		BreakpointRejected = { "", "Comment" },
		LogPoint = { "", "DiagnosticInfo" },
		Stopped = { "", "DiagnosticWarn" },
	}) do
		vim.fn.sign_define("Dap" .. name, {
			text = sign[1],
			texthl = sign[2],
			numhl = sign[2],
			linehl = name == "Stopped" and "debugPC" or "",
		})
	end

	dap.listeners.after.event_initialized.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		dapui.close()
	end

	local map, icon = Config.nmap_leader, Config.icon
	map("db", dap.toggle_breakpoint, " Toggle breakpoint")
	map("dB", function()
		vim.ui.input({ prompt = " Breakpoint condition: " }, function(condition)
			if condition then
				dap.set_breakpoint(condition)
			end
		end)
	end, " Conditional breakpoint")
	map("dc", dap.continue, icon("play") .. " Start / continue")
	map("dn", dap.step_over, " Step over")
	map("di", dap.step_into, " Step into")
	map("do", dap.step_out, " Step out")
	map("dt", dap.terminate, " Terminate debugging")
	map("dl", dap.run_last, icon("refresh") .. " Run last debug configuration")
	map("dr", dap.repl.toggle, icon("terminal") .. " Toggle debug REPL")
	map("du", dapui.toggle, icon("toggle") .. " Toggle debugger UI")
	map("de", function()
		dapui.eval()
	end, icon("hover") .. " Evaluate expression")
	Config.xmap_leader("de", function()
		dapui.eval()
	end, icon("hover") .. " Evaluate selection")

	Config.nmap("<F5>", dap.continue, icon("play") .. " Debug: start / continue")
	Config.nmap("<F9>", dap.toggle_breakpoint, " Debug: toggle breakpoint")
	Config.nmap("<F10>", dap.step_over, " Debug: step over")
	Config.nmap("<F11>", dap.step_into, " Debug: step into")
	Config.nmap("<S-F11>", dap.step_out, " Debug: step out")
	Config.nmap("<S-F5>", dap.terminate, " Debug: terminate")
end)
