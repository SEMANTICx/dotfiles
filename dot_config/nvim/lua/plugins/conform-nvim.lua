-- ================================================================================================
-- TITLE : conform.nvim
-- ABOUT : Lightweight formatter runner with LSP fallback.
-- LINKS :
--   > github : https://github.com/stevearc/conform.nvim
-- ================================================================================================

return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		formatters_by_ft = require("config.tools").formatters_by_ft,
	},
}
