-- ================================================================================================
-- TITLE : dropbar.nvim
-- ABOUT : Winbar breadcrumbs powered by file paths, Treesitter, and LSP symbols.
-- LINKS :
--   > github : https://github.com/Bekaboo/dropbar.nvim
-- ================================================================================================

return {
	"Bekaboo/dropbar.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{
			"<leader>;",
			function()
				require("dropbar.api").pick()
			end,
			desc = "Pick breadcrumb",
		},
	},
	opts = {
		bar = {
			padding = {
				left = 1,
				right = 1,
			},
			enable = function(buf, win, _)
				if vim.bo[buf].buftype ~= "" then
					return false
				end

				local filetype = vim.bo[buf].filetype
				if vim.tbl_contains({ "help", "oil", "qf", "trouble", "OverseerList" }, filetype) then
					return false
				end

				return vim.api.nvim_win_get_config(win).relative == ""
			end,
		},
		menu = {
			win_configs = {
				border = "rounded",
			},
		},
	},
}
