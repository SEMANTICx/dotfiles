-- ================================================================================================
-- TITLE : nvim-tree.lua
-- ABOUT : Tree-style project explorer that complements oil.nvim.
-- LINKS :
--   > github : https://github.com/nvim-tree/nvim-tree.lua
-- ================================================================================================

return {
	"nvim-tree/nvim-tree.lua",
	init = function()
		local group = vim.api.nvim_create_augroup("NvimTreeSeamlessEdge", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = "NvimTree",
			callback = function(args)
				vim.schedule(function()
					local win = vim.fn.bufwinid(args.buf)
					if win ~= -1 and vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_set_option_value(
							"fillchars",
							"eob: ,vert: ,vertleft: ,vertright: ,verthoriz: ",
							{ scope = "local", win = win }
						)
					end
				end)
			end,
		})
	end,
	cmd = {
		"NvimTreeClose",
		"NvimTreeFindFile",
		"NvimTreeFocus",
		"NvimTreeOpen",
		"NvimTreeRefresh",
		"NvimTreeToggle",
	},
	keys = {
		{
			"<leader>T",
			"<cmd>NvimTreeToggle<cr>",
			desc = "Tree: toggle project explorer",
		},
		{
			"<leader>F",
			"<cmd>NvimTreeFindFile<cr>",
			desc = "Tree: reveal current file",
		},
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		disable_netrw = true,
		hijack_netrw = false,
		hijack_directories = {
			enable = false,
			auto_open = false,
		},
		sync_root_with_cwd = true,
		respect_buf_cwd = true,
		view = {
			width = 34,
			side = "left",
		},
		renderer = {
			group_empty = true,
			highlight_git = true,
			highlight_opened_files = "name",
			root_folder_label = false,
			indent_markers = {
				enable = true,
				inline_arrows = true,
				icons = {
					corner = "└",
					edge = "│",
					item = "│",
					bottom = "─",
					none = " ",
				},
			},
			icons = {
				git_placement = "after",
				show = {
					file = true,
					folder = true,
					folder_arrow = true,
					git = true,
				},
				glyphs = {
					default = "󰈚",
					symlink = "",
					folder = {
						arrow_closed = "",
						arrow_open = "",
						default = "",
						open = "",
						empty = "",
						empty_open = "",
					},
					git = {
						unstaged = "",
						staged = "✓",
						unmerged = "",
						renamed = "➜",
						untracked = "★",
						deleted = "",
						ignored = "◌",
					},
				},
			},
		},
		filters = {
			dotfiles = false,
		},
		git = {
			enable = true,
			ignore = false,
		},
		diagnostics = {
			enable = true,
			show_on_dirs = true,
		},
		actions = {
			open_file = {
				quit_on_open = false,
				resize_window = true,
			},
		},
	},
}
