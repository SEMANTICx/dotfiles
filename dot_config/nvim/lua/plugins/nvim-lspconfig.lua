-- ================================================================================================
-- TITLE : nvim-lspconfig
-- ABOUT : Quickstart configurations for the built-in Neovim LSP client.
-- LINKS :
--   > github                  : https://github.com/neovim/nvim-lspconfig
--   > blink.cmp (dep)  : https://github.com/Saghen/blink.cmp
-- ================================================================================================

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp", -- completion capabilities for LSP clients
	},
	config = function()
		require("utils.diagnostics").setup()
		require("servers")
	end,
}
