-- ================================================================================================
-- TITLE : lualine.nvim
-- LINKS :
--   > github : https://github.com/nvim-lualine/lualine.nvim
-- ABOUT : A blazing fast and easy to configure Neovim statusline written in Lua.
-- ================================================================================================

return {
	"nvim-lualine/lualine.nvim",
	config = function()
		require("lualine").setup({
			options = {
				theme = "auto",
				icons_enabled = true,
				globalstatus = true,
				section_separators = { left = "", right = "" },
				component_separators = { left = "│", right = "│" },
				disabled_filetypes = {
					statusline = { "snacks_dashboard" },
				},
			},
			sections = {
				lualine_b = {
					"branch",
					"diff",
				},
				lualine_x = {
					"diagnostics",
					"encoding",
					"filetype",
				},
			},
		})
	end,
	dependencies = { "nvim-tree/nvim-web-devicons" },
}
