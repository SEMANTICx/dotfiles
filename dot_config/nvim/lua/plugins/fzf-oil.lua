-- ================================================================================================
-- TITLE : fzf-oil.nvim
-- ABOUT : Browse with fzf-lua and switch into oil.nvim without losing context.
-- LINKS :
--   > github : https://github.com/ingur/fzf-oil.nvim
-- ================================================================================================

local browser

return {
	"ingur/fzf-oil.nvim",
	version = "v2.1.0",
	dependencies = {
		"ibhagwan/fzf-lua",
		"stevearc/oil.nvim",
	},
	keys = {
		{
			"<leader>fo",
			function()
				browser.browse()
			end,
			desc = "FZF Oil: browse files",
		},
	},
	opts = {
		start_mode = "fzf",
	},
	config = function(_, opts)
		browser = require("fzf-oil").setup(opts)
	end,
}
