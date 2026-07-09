-- ================================================================================================
-- TITLE : catppuccin.nvim
-- ABOUT : Catppuccin Mocha colorscheme with transparent background support.
-- LINKS :
--   > github : https://github.com/catppuccin/nvim
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
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 999,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
				custom_highlights = function(colors)
					return {
						Visual = { bg = colors.surface1 },
						CursorLine = { bg = "NONE" },
						Cursor = { fg = colors.base, bg = colors.text },
						lCursor = { fg = colors.base, bg = colors.teal },
						TermCursor = { fg = colors.base, bg = colors.text },
						CursorLineNr = { fg = colors.yellow, bold = true },
						FloatBorder = { fg = colors.overlay1, bg = "NONE" },
						NormalFloat = { fg = colors.text, bg = "NONE" },
						NvimTreeNormal = { fg = colors.text, bg = colors.crust },
						NvimTreeNormalNC = { fg = colors.text, bg = colors.crust },
						NvimTreeEndOfBuffer = { fg = colors.crust, bg = colors.crust },
						NvimTreeCursorLine = { bg = colors.mantle },
						NvimTreeWinSeparator = { fg = colors.crust, bg = colors.crust },
						NvimTreeIndentMarker = { fg = colors.surface1, bg = colors.crust },
						NvimTreeFolderIcon = { fg = colors.teal, bg = colors.crust },
						NvimTreeFolderName = { fg = colors.subtext1, bg = colors.crust },
						NvimTreeOpenedFolderName = { fg = colors.yellow, bg = colors.crust, bold = true },
						NvimTreeFileIcon = { fg = colors.teal, bg = colors.crust },
						NvimTreeGitDirty = { fg = colors.yellow, bg = colors.crust },
						NvimTreeGitNew = { fg = colors.green, bg = colors.crust },
						NvimTreeGitDeleted = { fg = colors.red, bg = colors.crust },
						Pmenu = { fg = colors.text, bg = colors.mantle },
						PmenuSel = { fg = colors.text, bg = colors.surface1, bold = true },
						WinSeparator = { fg = colors.surface1 },
						StatusLine = { fg = colors.text, bg = colors.mantle },
						StatusLineNC = { fg = colors.overlay1, bg = colors.base },
						MsgArea = { fg = colors.text, bg = "NONE" },
						ModeMsg = { fg = colors.yellow, bg = "NONE", bold = true },
						MsgSeparator = { fg = colors.surface1, bg = "NONE" },
						MiniTrailspace = { bg = "NONE" },
						DropBarMenuNormalFloat = { fg = colors.text, bg = colors.mantle },
						DropBarMenuFloatBorder = { fg = colors.overlay1, bg = "NONE" },
						DropBarCurrentContext = { fg = colors.yellow, bold = true },
						DropBarIconUIIndicator = { fg = colors.teal },
						EdgyNormal = { fg = colors.text, bg = "NONE" },
						EdgyWinBar = { fg = colors.yellow, bg = "NONE", bold = true },
						EdgyTitle = { fg = colors.teal, bold = true },
						SnacksDashboardNormal = { fg = colors.text, bg = "NONE" },
						SnacksDashboardHeader = { fg = colors.text, bg = "NONE", bold = true },
						SnacksDashboardIcon = { fg = colors.teal, bg = "NONE" },
						SnacksDashboardDesc = { fg = colors.subtext1, bg = "NONE" },
						SnacksDashboardKey = { fg = colors.yellow, bg = "NONE", bold = true },
						SnacksDashboardFooter = { fg = colors.overlay1, bg = "NONE" },
						SnacksTerminal = { fg = colors.text, bg = "NONE" },
						SnacksTerminalBorder = { fg = colors.overlay1, bg = "NONE" },
					}
				end,
			})
			vim.cmd("colorscheme catppuccin")
		end,
	},
}
