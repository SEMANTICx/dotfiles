-- ================================================================================================
-- TITLE : csvview.nvim
-- ABOUT : Non-destructive tabular display, field text objects, and spreadsheet-like CSV navigation.
-- LINKS :
--   > github : https://github.com/hat0uma/csvview.nvim
-- ================================================================================================

return {
	"hat0uma/csvview.nvim",
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
	keys = {
		{ "<leader>cv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV table view" },
	},
	opts = {
		parser = {
			comments = { "#", "//" },
		},
		keymaps = {
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
			jump_next_row = { "<Enter>", mode = { "n", "v" } },
			jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
		},
	},
}
