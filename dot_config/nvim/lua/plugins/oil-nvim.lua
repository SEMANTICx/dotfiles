-- ================================================================================================
-- TITLE : oil.nvim
-- ABOUT : Edit directories like regular Neovim buffers.
-- LINKS :
--   > github : https://github.com/stevearc/oil.nvim
-- ================================================================================================

return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
	keys = {
		{
			"<leader>e",
			function()
				local zen_view = package.loaded["zen-mode.view"]
				if zen_view and zen_view.is_open() then
					require("zen-mode").close()
				end

				require("oil").open()
			end,
			desc = "Oil: edit current directory",
		},
		{
			"<leader>E",
			function()
				require("oil").open(vim.uv.cwd())
			end,
			desc = "Oil: edit cwd",
		},
	},
	opts = {
		default_file_explorer = true,
		columns = { "icon", "permissions", "size", "mtime" },
		view_options = {
			show_hidden = true,
		},
	},
}
