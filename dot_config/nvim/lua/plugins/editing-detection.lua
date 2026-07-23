-- ================================================================================================
-- TITLE : editing detection
-- ABOUT : Infer indentation in unconfigured projects and keep paired markup tags in sync.
-- ================================================================================================

local file_events = { "BufReadPre", "BufNewFile" }

return {
	{
		"tpope/vim-sleuth",
		event = file_events,
	},
	{
		"windwp/nvim-ts-autotag",
		event = file_events,
		opts = {},
	},
}
