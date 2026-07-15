-- ================================================================================================
-- TITLE : fzf-lua
-- LINKS :
--   > github : https://github.com/ibhagwan/fzf-lua
-- ABOUT : lua-based fzf wrapper and integration.
-- ================================================================================================

return {
	"ibhagwan/fzf-lua",
	cmd = "FzfLua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	keys = {
		{
			"<leader>ff",
			function()
				require("fzf-lua").files()
			end,
			desc = "FZF Files",
		},
		{
			"<leader>fg",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "FZF Live Grep",
		},
		{
			"<leader>fb",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "FZF Buffers",
		},
		{
			"<leader>fh",
			function()
				require("fzf-lua").help_tags()
			end,
			desc = "FZF Help Tags",
		},
		{
			"<leader>fx",
			function()
				require("fzf-lua").diagnostics_document()
			end,
			desc = "FZF Diagnostics Document",
		},
		{
			"<leader>fX",
			function()
				require("fzf-lua").diagnostics_workspace()
			end,
			desc = "FZF Diagnostics Workspace",
		},
		{
			"<leader>fs",
			function()
				require("fzf-lua").lsp_document_symbols()
			end,
			desc = "FZF Document Symbols",
		},
		{
			"<leader>fS",
			function()
				require("fzf-lua").lsp_workspace_symbols()
			end,
			desc = "FZF Workspace Symbols",
		},
	},

	opts = {
		winopts = {
			height = 0.82,
			width = 0.88,
			row = 0.50,
			col = 0.50,
			border = "rounded",
			backdrop = 70,
			title_pos = "center",
			preview = {
				border = "rounded",
				layout = "flex",
				horizontal = "right:55%",
				vertical = "down:45%",
				flip_columns = 100,
				title = true,
				title_pos = "center",
				scrollbar = "border",
				delay = 40,
				winopts = {
					number = true,
					relativenumber = false,
					cursorline = true,
					cursorlineopt = "both",
					signcolumn = "no",
				},
			},
		},
		fzf_colors = true,
		fzf_opts = {
			["--info"] = "inline-right",
			["--layout"] = "reverse",
			["--pointer"] = "",
			["--marker"] = "✓",
			["--ellipsis"] = "…",
			["--highlight-line"] = true,
		},
		defaults = {
			file_icons = "devicons",
			color_icons = true,
		},
		files = {
			prompt = "󰱼  Files ❯ ",
			git_icons = true,
			formatter = "path.filename_first",
		},
		grep = {
			prompt = "󰱽  Grep ❯ ",
		},
		buffers = {
			prompt = "󰈙  Buffers ❯ ",
			sort_lastused = true,
		},
		help_tags = {
			prompt = "󰋖  Help ❯ ",
		},
	},
}
