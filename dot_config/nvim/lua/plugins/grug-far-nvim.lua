-- ================================================================================================
-- TITLE : grug-far.nvim
-- ABOUT : Interactive project-wide search and replace with previews.
-- LINKS :
--   > github : https://github.com/MagicDuck/grug-far.nvim
-- ================================================================================================

return {
	"MagicDuck/grug-far.nvim",
	cmd = "GrugFar",
	keys = {
		{
			"<leader>ug",
			"<cmd>GrugFar<cr>",
			desc = "Search and replace",
		},
	},
	opts = {},
}
