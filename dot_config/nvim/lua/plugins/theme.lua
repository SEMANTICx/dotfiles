-- ================================================================================================
-- TITLE : gruvbox.nvim
-- ABOUT : Gruvbox Dark Hard colorscheme with transparent background support.
-- LINKS :
--   > github : https://github.com/ellisonleao/gruvbox.nvim
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
		"ellisonleao/gruvbox.nvim",
		lazy = false,
		priority = 999,
		config = function()
			local palette = {
				bg0_h = "#1d2021",
				bg0 = "#282828",
				bg1 = "#3c3836",
				bg2 = "#504945",
				bg4 = "#7c6f64",
				fg0 = "#fbf1c7",
				fg1 = "#ebdbb2",
				fg2 = "#d5c4a1",
				fg3 = "#bdae93",
				gray = "#928374",
				red = "#fb4934",
				green = "#b8bb26",
				yellow = "#fabd2f",
				aqua = "#8ec07c",
				orange = "#fe8019",
			}

			require("gruvbox").setup({
				contrast = "hard",
				transparent_mode = true,
				overrides = {
					Visual = { bg = palette.bg1 },
					CursorLine = { bg = "NONE" },
					Cursor = { fg = palette.bg0, bg = palette.fg0 },
					lCursor = { fg = palette.bg0, bg = palette.aqua },
					TermCursor = { fg = palette.bg0, bg = palette.fg0 },
					CursorLineNr = { fg = palette.yellow, bold = true },
					FloatBorder = { fg = palette.fg3, bg = "NONE" },
					NormalFloat = { fg = palette.fg1, bg = "NONE" },
					NvimTreeNormal = { fg = palette.fg1, bg = palette.bg0_h },
					NvimTreeNormalNC = { fg = palette.fg1, bg = palette.bg0_h },
					NvimTreeEndOfBuffer = { fg = palette.bg0_h, bg = palette.bg0_h },
					NvimTreeCursorLine = { bg = palette.bg0 },
					NvimTreeWinSeparator = { fg = palette.bg0_h, bg = palette.bg0_h },
					NvimTreeIndentMarker = { fg = palette.bg2, bg = palette.bg0_h },
					NvimTreeFolderIcon = { fg = palette.aqua, bg = palette.bg0_h },
					NvimTreeFolderName = { fg = palette.fg2, bg = palette.bg0_h },
					NvimTreeOpenedFolderName = { fg = palette.yellow, bg = palette.bg0_h, bold = true },
					NvimTreeFileIcon = { fg = palette.aqua, bg = palette.bg0_h },
					NvimTreeGitDirty = { fg = palette.yellow, bg = palette.bg0_h },
					NvimTreeGitNew = { fg = palette.green, bg = palette.bg0_h },
					NvimTreeGitDeleted = { fg = palette.red, bg = palette.bg0_h },
					Pmenu = { fg = palette.fg1, bg = palette.bg1 },
					PmenuSel = { fg = palette.fg0, bg = palette.bg2, bold = true },
					WinSeparator = { fg = palette.bg4 },
					StatusLine = { fg = palette.fg1, bg = palette.bg1 },
					StatusLineNC = { fg = palette.fg3, bg = palette.bg0 },
					MsgArea = { fg = palette.fg1, bg = "NONE" },
					ModeMsg = { fg = palette.yellow, bg = "NONE", bold = true },
					MsgSeparator = { fg = palette.bg4, bg = "NONE" },
					MiniTrailspace = { bg = "NONE" },
					DropBarMenuNormalFloat = { fg = palette.fg1, bg = palette.bg1 },
					DropBarMenuFloatBorder = { fg = palette.fg3, bg = "NONE" },
					DropBarCurrentContext = { fg = palette.yellow, bold = true },
					DropBarIconUIIndicator = { fg = palette.aqua },
					EdgyNormal = { fg = palette.fg1, bg = "NONE" },
					EdgyWinBar = { fg = palette.yellow, bg = "NONE", bold = true },
					EdgyTitle = { fg = palette.aqua, bold = true },
					SnacksDashboardNormal = { fg = palette.fg1, bg = "NONE" },
					SnacksDashboardHeader = { fg = palette.fg0, bg = "NONE", bold = true },
					SnacksDashboardIcon = { fg = palette.aqua, bg = "NONE" },
					SnacksDashboardDesc = { fg = palette.fg2, bg = "NONE" },
					SnacksDashboardKey = { fg = palette.yellow, bg = "NONE", bold = true },
					SnacksDashboardFooter = { fg = palette.gray, bg = "NONE" },
					SnacksTerminal = { fg = palette.fg1, bg = "NONE" },
					SnacksTerminalBorder = { fg = palette.fg3, bg = "NONE" },
				},
			})
			vim.cmd("colorscheme gruvbox")
		end,
	},
}
