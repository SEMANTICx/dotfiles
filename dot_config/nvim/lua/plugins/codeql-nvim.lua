local function has_codeql()
	return vim.fn.executable("codeql") == 1
end

return {
	"pwntester/codeql.nvim",
	enabled = has_codeql,
	ft = { "ql", "qll" },
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
		{
			"s1n7ax/nvim-window-picker",
			version = "v1.*",
			opts = {
				autoselect_one = true,
				include_current = false,
				filter_rules = {
					bo = {
						filetype = { "codeql_panel", "codeql_explorer", "qf", "TelescopePrompt", "TelescopeResults" },
						buftype = { "terminal" },
					},
				},
			},
		},
	},
	config = function()
		require("codeql").setup({
			format_on_save = false,
			additional_packs = { vim.fn.expand("~/.codeql") },
			mappings = {
				run_query = { modes = { "n" }, lhs = "<leader>qr", desc = "CodeQL run query" },
				quick_eval = { modes = { "x", "n" }, lhs = "<leader>qe", desc = "CodeQL quick evaluate" },
				quick_eval_predicate = { modes = { "n" }, lhs = "<leader>qp", desc = "CodeQL evaluate predicate" },
			},
		})
	end,
}
