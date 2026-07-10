-- ================================================================================================
-- TITLE : nvim-lspconfig
-- ABOUT : Quickstart configurations for the built-in Neovim LSP client.
-- LINKS :
--   > github                  : https://github.com/neovim/nvim-lspconfig
--   > mason.nvim (dep) : https://github.com/mason-org/mason.nvim
--   > blink.cmp (dep)  : https://github.com/Saghen/blink.cmp
-- ================================================================================================

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} }, -- LSP/DAP/Linter installer & manager
		"saghen/blink.cmp", -- completion capabilities for LSP clients
	},
	config = function()
		require("utils.diagnostics").setup()
		require("servers")
	end,
}
