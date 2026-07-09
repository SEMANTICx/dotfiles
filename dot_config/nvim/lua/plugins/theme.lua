-- ================================================================================================
-- TITLE : kanagawa.nvim
-- ABOUT : Kanagawa Dragon colorscheme with transparent background support.
-- LINKS :
--   > github : https://github.com/rebelot/kanagawa.nvim
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
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 999,
		config = function()
			local palette = {
				bg0 = "#0d0c0c",
				bg1 = "#12120f",
				bg2 = "#181616",
				bg3 = "#1d1c19",
				fg0 = "#c5c9c5",
				fg1 = "#a6a69c",
				fg2 = "#9e9b93",
				fg3 = "#7a8382",
				red = "#c4746e",
				green = "#87a987",
				yellow = "#c4b28a",
				teal = "#8ea4a2",
				blue = "#8ba4b0",
				purple = "#a292a3",
			}

			require("kanagawa").setup({
				transparent = true,
				theme = "dragon",
				background = {
					dark = "dragon",
				},
				overrides = function()
					return {
						Visual = { bg = palette.bg3 },
						CursorLine = { bg = "NONE" },
						Cursor = { fg = palette.bg0, bg = palette.fg0 },
						lCursor = { fg = palette.bg0, bg = palette.teal },
						TermCursor = { fg = palette.bg0, bg = palette.fg0 },
						CursorLineNr = { fg = palette.yellow, bold = true },
						FloatBorder = { fg = palette.fg3, bg = "NONE" },
						NormalFloat = { fg = palette.fg0, bg = "NONE" },
						NvimTreeNormal = { fg = palette.fg0, bg = palette.bg1 },
						NvimTreeNormalNC = { fg = palette.fg0, bg = palette.bg1 },
						NvimTreeEndOfBuffer = { fg = palette.bg1, bg = palette.bg1 },
						NvimTreeCursorLine = { bg = palette.bg2 },
						NvimTreeWinSeparator = { fg = palette.bg1, bg = palette.bg1 },
						NvimTreeIndentMarker = { fg = palette.bg3, bg = palette.bg1 },
						NvimTreeFolderIcon = { fg = palette.teal, bg = palette.bg1 },
						NvimTreeFolderName = { fg = palette.fg1, bg = palette.bg1 },
						NvimTreeOpenedFolderName = { fg = palette.yellow, bg = palette.bg1, bold = true },
						NvimTreeFileIcon = { fg = palette.teal, bg = palette.bg1 },
						NvimTreeGitDirty = { fg = palette.yellow, bg = palette.bg1 },
						NvimTreeGitNew = { fg = palette.green, bg = palette.bg1 },
						NvimTreeGitDeleted = { fg = palette.red, bg = palette.bg1 },
						Pmenu = { fg = palette.fg0, bg = palette.bg2 },
						PmenuSel = { fg = palette.fg0, bg = palette.bg3, bold = true },
						WinSeparator = { fg = palette.bg3 },
						StatusLine = { fg = palette.fg0, bg = palette.bg2 },
						StatusLineNC = { fg = palette.fg3, bg = palette.bg1 },
						MsgArea = { fg = palette.fg0, bg = "NONE" },
						ModeMsg = { fg = palette.yellow, bg = "NONE", bold = true },
						MsgSeparator = { fg = palette.bg3, bg = "NONE" },
						MiniTrailspace = { bg = "NONE" },
						DropBarMenuNormalFloat = { fg = palette.fg0, bg = palette.bg2 },
						DropBarMenuFloatBorder = { fg = palette.fg3, bg = "NONE" },
						DropBarCurrentContext = { fg = palette.yellow, bold = true },
						DropBarIconUIIndicator = { fg = palette.teal },
						EdgyNormal = { fg = palette.fg0, bg = "NONE" },
						EdgyWinBar = { fg = palette.yellow, bg = "NONE", bold = true },
						EdgyTitle = { fg = palette.teal, bold = true },
						SnacksDashboardNormal = { fg = palette.fg0, bg = "NONE" },
						SnacksDashboardHeader = { fg = palette.fg0, bg = "NONE", bold = true },
						SnacksDashboardIcon = { fg = palette.teal, bg = "NONE" },
						SnacksDashboardDesc = { fg = palette.fg1, bg = "NONE" },
						SnacksDashboardKey = { fg = palette.yellow, bg = "NONE", bold = true },
						SnacksDashboardFooter = { fg = palette.fg3, bg = "NONE" },
						SnacksTerminal = { fg = palette.fg0, bg = "NONE" },
						SnacksTerminalBorder = { fg = palette.fg3, bg = "NONE" },
					}
				end,
			})
			vim.cmd("colorscheme kanagawa-dragon")
		end,
	},
}
