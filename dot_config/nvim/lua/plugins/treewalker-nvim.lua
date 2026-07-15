return {
	"aaronik/treewalker.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = { "BufReadPost", "BufNewFile" },
	keys = {
		{ "<C-S-k>", "<cmd>Treewalker Up<cr>", mode = { "n", "x" }, desc = "Treewalker up" },
		{ "<C-S-j>", "<cmd>Treewalker Down<cr>", mode = { "n", "x" }, desc = "Treewalker down" },
		{ "<C-S-h>", "<cmd>Treewalker Left<cr>", mode = { "n", "x" }, desc = "Treewalker left" },
		{ "<C-S-l>", "<cmd>Treewalker Right<cr>", mode = { "n", "x" }, desc = "Treewalker right" },
	},
	opts = {
		highlight = true,
		highlight_duration = 250,
		highlight_group = "CursorLine",
		select = false,
		jumplist = true,
	},
}
