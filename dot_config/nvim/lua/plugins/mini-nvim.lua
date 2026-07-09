-- ================================================================================================
-- TITLE : mini.nvim
-- LINKS :
--   > github : https://github.com/echasnovski/mini.nvim
-- ABOUT : Library of 40+ independent Lua modules.
-- ================================================================================================

return {
	{ "echasnovski/mini.ai", version = "*", opts = {} },
	{ "echasnovski/mini.comment", version = "*", opts = {} },
	{
		"echasnovski/mini.move",
		version = "*",
		opts = {
			mappings = {
				left = "<leader>mh",
				right = "<leader>ml",
				down = "<leader>mj",
				up = "<leader>mk",
				line_left = "<leader>mh",
				line_right = "<leader>ml",
				line_down = "<leader>mj",
				line_up = "<leader>mk",
			},
		},
	},
	{ "echasnovski/mini.surround", version = "*", opts = {} },
	{ "echasnovski/mini.cursorword", version = "*", opts = {} },
	{ "echasnovski/mini.indentscope", version = "*", opts = {} },
	{ "echasnovski/mini.pairs", version = "*", opts = {} },
	{
		"echasnovski/mini.trailspace",
		version = "*",
		config = function()
			require("mini.trailspace").setup()

			local original_highlight = MiniTrailspace.highlight
			MiniTrailspace.highlight = function()
				if vim.bo.filetype == "snacks_dashboard" then
					MiniTrailspace.unhighlight()
					return
				end
				original_highlight()
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "snacks_dashboard",
				callback = function()
					vim.b.minitrailspace_disable = true
					MiniTrailspace.unhighlight()
					pcall(vim.fn.clearmatches)
				end,
			})
		end,
	},
	{ "echasnovski/mini.bufremove", version = "*", opts = {} },
	{ "echasnovski/mini.notify", version = "*", enabled = false },
}
