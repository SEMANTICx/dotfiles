-- ================================================================================================
-- TITLE : flash.nvim
-- ABOUT : Fast label-based navigation and Treesitter-aware selections.
-- LINKS :
--   > github : https://github.com/folke/flash.nvim
-- ================================================================================================

return {
	"folke/flash.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"<leader>j",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash jump",
		},
		{
			"<leader>J",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter search",
		},
		{
			"<C-s>",
			mode = "c",
			function()
				require("flash").toggle()
			end,
			desc = "Toggle flash search",
		},
	},
}
