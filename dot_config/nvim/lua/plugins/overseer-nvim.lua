-- ================================================================================================
-- TITLE : overseer.nvim
-- ABOUT : Task runner and job management for project commands.
-- LINKS :
--   > github : https://github.com/stevearc/overseer.nvim
-- ================================================================================================

return {
	"stevearc/overseer.nvim",
	cmd = {
		"OverseerBuild",
		"OverseerClearCache",
		"OverseerClose",
		"OverseerDeleteBundle",
		"OverseerInfo",
		"OverseerLoadBundle",
		"OverseerOpen",
		"OverseerQuickAction",
		"OverseerRun",
		"OverseerRunCmd",
		"OverseerSaveBundle",
		"OverseerTaskAction",
		"OverseerToggle",
	},
	keys = {
		{
			"<leader>or",
			"<cmd>OverseerRun<cr>",
			desc = "Run task",
		},
		{
			"<leader>ot",
			"<cmd>OverseerToggle<cr>",
			desc = "Toggle tasks",
		},
		{
			"<leader>oq",
			"<cmd>OverseerQuickAction<cr>",
			desc = "Task quick action",
		},
	},
	opts = {},
}
