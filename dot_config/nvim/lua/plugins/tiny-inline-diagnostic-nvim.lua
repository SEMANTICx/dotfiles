-- ================================================================================================
-- TITLE : tiny-inline-diagnostic.nvim
-- ABOUT : Compact inline diagnostic messages with less visual noise than default virtual text.
-- LINKS :
--   > github : https://github.com/rachartier/tiny-inline-diagnostic.nvim
-- ================================================================================================

return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "LspAttach",
	priority = 1000,
	config = function()
		vim.diagnostic.config({
			virtual_text = false,
			virtual_lines = false,
		})

		require("tiny-inline-diagnostic").setup({
			preset = "ghost",
			transparent_bg = true,
			transparent_cursorline = true,
			hi = {
				background = "None",
			},
			options = {
				enable_on_insert = false,
				show_all_diags_on_cursorline = true,
				use_icons_from_diagnostic = true,
				show_source = {
					enabled = true,
					if_many = true,
				},
				multilines = {
					enabled = true,
					always_show = false,
				},
				overflow = {
					mode = "wrap",
					padding = 2,
				},
			},
		})
	end,
}
