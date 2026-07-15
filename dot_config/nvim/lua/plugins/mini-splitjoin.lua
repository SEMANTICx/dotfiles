-- ================================================================================================
-- TITLE : mini.splitjoin
-- ABOUT : Toggle bracketed arguments between compact and one-item-per-line layouts.
-- LINKS :
--   > github : https://github.com/echasnovski/mini.splitjoin
-- ================================================================================================

return {
	"echasnovski/mini.splitjoin",
	version = "*",
	keys = {
		{
			"<leader>cj",
			function()
				require("mini.splitjoin").toggle()
			end,
			mode = { "n", "x" },
			desc = "Toggle split/join arguments",
		},
	},
	opts = {
		mappings = {
			toggle = "",
			split = "",
			join = "",
		},
	},
}
