-- ================================================================================================
-- TITLE : bufferline.nvim
-- ABOUT : Buffer tabs with diagnostics and NvimTree alignment.
-- LINKS :
--   > github : https://github.com/akinsho/bufferline.nvim
-- ================================================================================================

local function clear_bufferline_backgrounds()
	local groups = vim.fn.getcompletion("BufferLine", "highlight")
	local config = require("bufferline.config").get()

	for _, highlight in pairs(config and config.highlights or {}) do
		if highlight.hl_group then
			groups[#groups + 1] = highlight.hl_group
		end
	end

	for _, group in ipairs(vim.fn.uniq(vim.fn.sort(groups))) do
		local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
		highlight.bg = nil
		highlight.ctermbg = nil
		highlight.default = nil
		vim.api.nvim_set_hl(0, group, highlight)
	end
end

local bufferline_keys = {
	{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
	{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
	{ "<leader>bP", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
	{ "<leader>bH", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
	{ "<leader>bL", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
	{ "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
	{ "<leader>b[", "<cmd>BufferLineCloseLeft<cr>", desc = "Close buffers to the left" },
	{ "<leader>b]", "<cmd>BufferLineCloseRight<cr>", desc = "Close buffers to the right" },
}

return {
	"akinsho/bufferline.nvim",
	version = "*",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = bufferline_keys,
	config = function(_, opts)
		vim.o.mousemoveevent = true
		require("bufferline").setup(opts)
		clear_bufferline_backgrounds()
		vim.schedule(clear_bufferline_backgrounds)

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("TransparentBufferline", { clear = true }),
			callback = function()
				vim.schedule(clear_bufferline_backgrounds)
			end,
			desc = "Keep Bufferline backgrounds transparent",
		})
	end,
	opts = {
		highlights = {
			buffer_selected = {
				fg = { attribute = "fg", highlight = "WinBar" },
				bold = true,
				italic = false,
			},
			separator = { fg = { attribute = "fg", highlight = "WinSeparator" } },
			separator_visible = { fg = { attribute = "fg", highlight = "WinSeparator" } },
			separator_selected = { fg = { attribute = "fg", highlight = "WinSeparator" } },
		},
		options = {
			mode = "buffers",
			numbers = "none",
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,
			diagnostics_update_in_insert = false,
			close_command = function(bufnr)
				require("snacks.bufdelete")(bufnr)
			end,
			right_mouse_command = function(bufnr)
				require("snacks.bufdelete")(bufnr)
			end,
			indicator = {
				style = "none",
			},
			separator_style = { "│", "│" },
			show_buffer_close_icons = true,
			show_close_icon = false,
			show_duplicate_prefix = true,
			always_show_bufferline = false,
			sort_by = "insert_after_current",
			hover = {
				enabled = true,
				delay = 200,
				reveal = { "close" },
			},
			offsets = {
				{
					filetype = "NvimTree",
					text = "Explorer",
					text_align = "center",
					separator = true,
				},
			},
		},
	},
}
