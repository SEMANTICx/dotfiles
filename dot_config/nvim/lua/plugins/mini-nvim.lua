-- ================================================================================================
-- TITLE : mini.nvim
-- LINKS :
--   > github : https://github.com/echasnovski/mini.nvim
-- ABOUT : Library of 40+ independent Lua modules.
-- ================================================================================================

return {
	{ "echasnovski/mini.ai", version = "*", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.move", version = "*", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.surround", version = "*", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.cursorword", version = "*", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.indentscope", version = "*", event = "VeryLazy", opts = {} },
	{ "echasnovski/mini.pairs", version = "*", event = "InsertEnter", opts = {} },
	{
		"echasnovski/mini.trailspace",
		version = "*",
		lazy = true,
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
	{ "echasnovski/mini.notify", version = "*", enabled = false },
}
