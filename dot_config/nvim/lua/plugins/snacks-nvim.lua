-- ================================================================================================
-- TITLE : snacks.nvim
-- ABOUT : Focused UI quality-of-life modules for dashboard, terminal, input, scroll, and statuscolumn.
-- LINKS :
--   > github : https://github.com/folke/snacks.nvim
-- ================================================================================================

local ghostty_dashboard = require("ui.ghostty_dashboard")

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{
			"<leader>t",
			function()
				require("snacks.terminal")(nil, {
					cwd = vim.uv.cwd(),
				})
			end,
			desc = "Toggle terminal",
		},
		{
			"<leader>bd",
			function()
				require("snacks.bufdelete")()
			end,
			desc = "Delete buffer",
		},
	},
	opts = {
		dashboard = {
			enabled = true,
			width = ghostty_dashboard.width,
			row = nil,
			pane_gap = ghostty_dashboard.pane_gap,
			preset = {
				keys = {
					{
						icon = " ",
						key = "f",
						desc = "Find File",
						action = function()
							require("fzf-lua").files()
						end,
					},
					{
						icon = " ",
						key = "n",
						desc = "New File",
						action = ":ene | startinsert",
					},
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = function()
							require("fzf-lua").live_grep()
						end,
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = function()
							require("fzf-lua").oldfiles()
						end,
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = function()
							require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
						end,
					},
					{
						icon = "󰒲 ",
						key = "L",
						desc = "Lazy",
						action = ":Lazy",
					},
					{
						icon = " ",
						key = "t",
						desc = "Terminal",
						action = function()
							require("snacks.terminal")(nil, { cwd = vim.uv.cwd() })
						end,
					},
					{
						icon = " ",
						key = "q",
						desc = "Quit",
						action = ":qa",
					},
				},
			},
			sections = ghostty_dashboard.sections(),
		},
		input = {
			enabled = true,
		},
		scroll = {
			enabled = true,
		},
		statuscolumn = {
			enabled = true,
		},
		terminal = {
			enabled = true,
			win = {
				border = "rounded",
			},
		},
		notifier = {
			enabled = true,
		},
		picker = {
			enabled = false,
		},
		explorer = {
			enabled = false,
		},
	},
	config = function(_, opts)
		require("snacks").setup(opts)
		pcall(function()
			require("snacks.input").enable()
		end)
		ghostty_dashboard.setup()
	end,
}
