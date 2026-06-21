return {
	"rcarriga/nvim-dap-ui",
	lazy = true,
	dependencies = {
		"nvim-neotest/nvim-nio",
		"mfussenegger/nvim-dap",
	},
	keys = {
		{
			"<leader>dU",
			function()
				require("dapui").toggle()
			end,
			desc = "Toggle debug UI",
		},
	},
	config = function()
		local dap, dapui = require("dap"), require("dapui")

		dapui.setup()

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end
	end,
}
