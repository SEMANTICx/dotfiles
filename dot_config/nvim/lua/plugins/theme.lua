-- ================================================================================================
-- TITLE : nightfox.nvim
-- ABOUT : Duskfox colorscheme with transparent background support.
-- LINKS :
--   > github : https://github.com/EdenEast/nightfox.nvim
-- ================================================================================================

return {
	{
		"xiyaowong/nvim-transparent",
		lazy = false,
		priority = 999,
		opts = {
			extra_groups = {
				"OilDir",
				"OilFile",
				"CursorLine",
				"NormalFloat",
				"FloatBorder",
			},
		},
	},
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 999,
		config = function()
			local palette = require("nightfox.palette").load("duskfox")

			require("nightfox").setup({
				options = {
					transparent = true,
				},
				groups = {
					duskfox = {
						Visual = { bg = palette.bg1 },
						CursorLine = { bg = "None" },
						Cursor = { fg = palette.bg0, bg = palette.white.base },
						lCursor = { fg = palette.bg0, bg = palette.cyan.base },
						TermCursor = { fg = palette.bg0, bg = palette.white.base },
						CursorLineNr = { fg = palette.yellow.base, style = "bold" },
						FloatBorder = { fg = palette.fg3, bg = "None" },
						NormalFloat = { fg = palette.fg1, bg = "None" },
						Pmenu = { fg = palette.fg1, bg = palette.bg1 },
						PmenuSel = { fg = palette.fg0, bg = palette.sel0, style = "bold" },
						WinSeparator = { fg = palette.bg4 },
						StatusLine = { fg = palette.fg1, bg = palette.bg1 },
						StatusLineNC = { fg = palette.fg3, bg = palette.bg0 },
						MsgArea = { fg = palette.fg1, bg = "None" },
						ModeMsg = { fg = palette.yellow.base, bg = "None", style = "bold" },
						MsgSeparator = { fg = palette.bg4, bg = "None" },
						MiniTrailspace = { bg = "None" },
						DropBarMenuNormalFloat = { fg = palette.fg1, bg = palette.bg1 },
						DropBarMenuFloatBorder = { fg = palette.fg3, bg = "None" },
						DropBarCurrentContext = { fg = palette.yellow.base, style = "bold" },
						DropBarIconUIIndicator = { fg = palette.cyan.base },
						EdgyNormal = { fg = palette.fg1, bg = "None" },
						EdgyWinBar = { fg = palette.yellow.base, bg = "None", style = "bold" },
						EdgyTitle = { fg = palette.cyan.base, style = "bold" },
						SnacksDashboardNormal = { fg = palette.fg1, bg = "None" },
						SnacksDashboardHeader = { fg = palette.white.base, bg = "None", style = "bold" },
						SnacksDashboardIcon = { fg = palette.cyan.base, bg = "None" },
						SnacksDashboardDesc = { fg = palette.fg2, bg = "None" },
						SnacksDashboardKey = { fg = palette.yellow.base, bg = "None", style = "bold" },
						SnacksDashboardFooter = { fg = palette.comment, bg = "None" },
						SnacksTerminal = { fg = palette.fg1, bg = "None" },
						SnacksTerminalBorder = { fg = palette.fg3, bg = "None" },
					},
				},
			})
			vim.cmd("colorscheme duskfox")
		end,
	},
}
