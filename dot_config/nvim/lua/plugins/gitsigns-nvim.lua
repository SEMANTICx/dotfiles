-- ================================================================================================
-- TITLE : gitsigns.nvim
-- LINKS :
--   > github : https://github.com/lewis6991/gitsigns.nvim
-- ABOUT : deep buffer integration for git.
-- ================================================================================================

return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
		signs_staged = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
		current_line_blame = false,
		current_line_blame_opts = {
			delay = 500,
			virt_text_pos = "eol",
		},
		preview_config = {
			border = "rounded",
		},
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")
			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
			end

			map("n", "]h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end, "Next git hunk")

			map("n", "[h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, "Previous git hunk")

			map({ "n", "v" }, "<leader>hs", gitsigns.stage_hunk, "Stage git hunk")
			map({ "n", "v" }, "<leader>hr", gitsigns.reset_hunk, "Reset git hunk")
			map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
			map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
			map("n", "<leader>hp", gitsigns.preview_hunk, "Preview git hunk")
			map("n", "<leader>hb", gitsigns.blame_line, "Blame line")
			map("n", "<leader>hB", gitsigns.toggle_current_line_blame, "Toggle git blame")
			map("n", "<leader>hd", gitsigns.diffthis, "Diff this")
			map("n", "<leader>hD", function()
				gitsigns.diffthis("~")
			end, "Diff this against HEAD~")
		end,
	},
}
