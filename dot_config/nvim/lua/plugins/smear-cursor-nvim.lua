-- ================================================================================================
-- TITLE : smear-cursor.nvim
-- ABOUT : Smooth cursor smear animation for terminals.
-- LINKS :
--   > github : https://github.com/sphamba/smear-cursor.nvim
-- ================================================================================================

return {
	"sphamba/smear-cursor.nvim",
	event = "VeryLazy",
	keys = {
		{ "<leader>uc", "<cmd>SmearCursorToggle<cr>", desc = "Toggle cursor smear" },
	},
	opts = {
		enabled = true,
		cursor_color = "#e0def4",
		transparent_bg_fallback_color = "#232136",
		stiffness = 0.75,
		trailing_stiffness = 0.45,
		trailing_exponent = 4,
		distance_stop_animating = 0.35,
		never_draw_over_target = true,
		hide_target_hack = true,
		smear_between_buffers = false,
		smear_between_neighbor_lines = true,
		filetypes_disabled = { "snacks_dashboard" },
		smear_insert_mode = false,
		scroll_buffer_space = false,
	},
}
