-- ================================================================================================
-- TITLE : mason-tool-installer.nvim
-- ABOUT : Ensure LSP servers, formatters, linters, and debuggers used by this config are installed.
-- LINKS :
--   > github : https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
-- ================================================================================================

return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate" },
	dependencies = {
		{
			"mason-org/mason.nvim",
			cmd = "Mason",
			opts = {},
		},
	},
	opts = {
		ensure_installed = require("config.tools").mason_tools,
		auto_update = false,
		run_on_start = false,
	},
}
