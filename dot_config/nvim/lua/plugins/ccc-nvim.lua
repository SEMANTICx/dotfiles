-- ================================================================================================
-- TITLE : ccc.nvim
-- LINKS :
--   > github : https://github.com/uga-rosa/ccc.nvim
-- ABOUT : colour picker & highlighter for neovim
-- ================================================================================================

return {
	"uga-rosa/ccc.nvim",
	cmd = {
		"CccConvert",
		"CccHighlighterDisable",
		"CccHighlighterEnable",
		"CccHighlighterToggle",
		"CccPick",
	},
	config = function()
		require("ccc").setup({
			highlighter = {
				auto_enable = true, -- enable highlight automatically
				lsp = true, -- highlight colors from LSP too
			},
			highlight_mode = "virtual", -- small circles with colour next to the declaration
		})
	end,
}
