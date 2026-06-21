-- ================================================================================================
-- TITLE : todo-comments.nvim
-- ABOUT : Highlight and search TODO, FIXME, NOTE, and similar comment markers.
-- LINKS :
--   > github : https://github.com/folke/todo-comments.nvim
-- ================================================================================================

return {
	"folke/todo-comments.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{
			"]t",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Next todo comment",
		},
		{
			"[t",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Previous todo comment",
		},
		{
			"<leader>fT",
			"<cmd>TodoFzfLua<cr>",
			desc = "Find todo comments",
		},
	},
	opts = {},
}
