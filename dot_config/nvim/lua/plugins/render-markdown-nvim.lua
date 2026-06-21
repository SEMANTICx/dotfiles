-- ================================================================================================
-- TITLE : render-markdown.nvim
-- ABOUT : Inline Markdown rendering for notes and documentation.
-- LINKS :
--   > github : https://github.com/MeanderingProgrammer/render-markdown.nvim
-- ================================================================================================

return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = { "markdown" },
	opts = {
		file_types = { "markdown" },
		latex = {
			enabled = false,
		},
	},
	keys = {
		{
			"<leader>mr",
			"<cmd>RenderMarkdown toggle<cr>",
			desc = "Toggle markdown render",
		},
	},
}
