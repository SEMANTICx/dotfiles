-- ================================================================================================
-- TITLE : diffview.nvim
-- ABOUT : Single-tabpage interface for reviewing git diffs and file history.
-- LINKS :
--   > github : https://github.com/sindrets/diffview.nvim
-- ================================================================================================

return {
	"sindrets/diffview.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	cmd = {
		"DiffviewOpen",
		"DiffviewFileHistory",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
	},
	keys = {
		{
			"<leader>gv",
			"<cmd>DiffviewOpen<cr>",
			desc = "Git diff view",
		},
		{
			"<leader>gV",
			"<cmd>DiffviewOpen -- %<cr>",
			desc = "Git diff current file",
		},
		{
			"<leader>gh",
			"<cmd>DiffviewFileHistory<cr>",
			desc = "Git file history",
		},
		{
			"<leader>gH",
			"<cmd>DiffviewFileHistory %<cr>",
			desc = "Git current file history",
		},
		{
			"<leader>gq",
			"<cmd>DiffviewClose<cr>",
			desc = "Close git diff view",
		},
	},
	opts = {},
}
