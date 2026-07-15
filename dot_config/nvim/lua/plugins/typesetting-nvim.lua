return {
	{
		"chomosuke/typst-preview.nvim",
		version = "1.*",
		ft = "typst",
		keys = {
			{ "<leader>wp", "<cmd>TypstPreviewToggle<cr>", desc = "Writing: Typst preview" },
			{ "<leader>wf", "<cmd>TypstPreviewFollowCursorToggle<cr>", desc = "Writing: Typst follow cursor" },
			{ "<leader>ws", "<cmd>TypstPreviewSyncCursor<cr>", desc = "Writing: Typst sync cursor" },
			{ "<leader>wn", "<cmd>TypstPreviewNoFollowCursor<cr>", desc = "Writing: Typst stop following" },
		},
		opts = {},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		ft = "typst",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@math.inner"] = "v",
						["@math.outer"] = "V",
					},
					include_surrounding_whitespace = false,
				},
			})

			local function attach(bufnr)
				if vim.bo[bufnr].filetype ~= "typst" or vim.b[bufnr].typst_math_textobjects then
					return
				end

				vim.b[bufnr].typst_math_textobjects = true
				local select = require("nvim-treesitter-textobjects.select")
				vim.keymap.set({ "x", "o" }, "am", function()
					select.select_textobject("@math.outer", "textobjects")
				end, { buffer = bufnr, desc = "Select around Typst math" })
				vim.keymap.set({ "x", "o" }, "im", function()
					select.select_textobject("@math.inner", "textobjects")
				end, { buffer = bufnr, desc = "Select inside Typst math" })
			end

			attach(vim.api.nvim_get_current_buf())
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("TypstMathTextobjects", { clear = true }),
				pattern = "typst",
				callback = function(args)
					attach(args.buf)
				end,
			})
		end,
	},
}
