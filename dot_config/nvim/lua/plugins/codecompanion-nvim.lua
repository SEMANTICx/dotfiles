-- ================================================================================================
-- TITLE : codecompanion.nvim
-- ABOUT : AI coding assistant with chat, inline prompts, and action palette.
-- LINKS :
--   > github : https://github.com/olimorris/codecompanion.nvim
-- ================================================================================================

local ai = require("config.ai")

return {
	"olimorris/codecompanion.nvim",
	cmd = {
		"CodeCompanion",
		"CodeCompanionActions",
		"CodeCompanionChat",
		"CodeCompanionCmd",
	},
	keys = {
		{
			"<leader>aa",
			ai.run("CodeCompanionActions"),
			mode = { "n", "v" },
			desc = "AI actions",
		},
		{
			"<leader>ac",
			ai.run("CodeCompanionChat Toggle"),
			mode = { "n", "v" },
			desc = "AI chat",
		},
		{
			"<leader>ai",
			ai.run("CodeCompanion"),
			mode = { "n", "v" },
			desc = "AI inline prompt",
		},
		{
			"<leader>am",
			ai.run("CodeCompanionCmd"),
			desc = "AI command prompt",
		},
	},
	init = function()
		ai.setup_commands()
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	opts = ai.opts(),
	config = function(_, opts)
		ai.notify_missing_credentials()
		require("codecompanion").setup(opts)
	end,
}
