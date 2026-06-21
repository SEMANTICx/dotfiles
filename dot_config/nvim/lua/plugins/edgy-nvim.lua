-- ================================================================================================
-- TITLE : edgy.nvim
-- ABOUT : Stable edge layouts for sidebars and bottom panels.
-- LINKS :
--   > github : https://github.com/folke/edgy.nvim
-- ================================================================================================

return {
	"folke/edgy.nvim",
	event = "VeryLazy",
	opts = {
		animate = {
			enabled = false,
		},
		icons = {
			closed = "",
			open = "",
		},
		left = {
			{
				ft = "oil",
				title = "Files",
				size = { width = 34 },
			},
		},
		right = {
			{
				ft = "trouble",
				title = "Trouble",
				size = { width = 44 },
			},
		},
		bottom = {
			{
				ft = "OverseerList",
				title = "Tasks",
				size = { height = 12 },
			},
			{
				ft = "qf",
				title = "Quickfix",
				size = { height = 10 },
			},
			{
				ft = "help",
				title = "Help",
				size = { height = 14 },
				filter = function(buf)
					return vim.bo[buf].buftype == "help"
				end,
			},
		},
	},
}
