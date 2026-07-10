return {
	"https://github.com/obsidian-nvim/obsidian.nvim",
	ft = { "markdown" },
	cmd = "Obsidian",
	keys = {
		{ "<leader>nn", "<cmd>Obsidian new<cr>", desc = "New Note" },
		{ "<leader>nf", "<cmd>Obsidian quick_switch<cr>", desc = "Find note" },
		{ "<leader>ns", "<cmd>Obsidian search<cr>", desc = "Search notes" },
		{ "<leader>nt", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
	},
	config = function()
		local workspace_path = vim.env.OBSIDIAN_VAULT
		if not workspace_path or workspace_path == "" then
			workspace_path = "~/Documents/Notes"
		end
		workspace_path = vim.fn.expand(workspace_path)

		require("obsidian").setup({
			legacy_commands = false,
			ui = {
				enable = false,
			},
			workspaces = {
				{ name = "Notes", path = workspace_path },
			},
			picker = { name = "fzf-lua" },
		})
	end,
}
