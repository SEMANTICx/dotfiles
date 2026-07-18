-- ================================================================================================
-- TITLE : snacks.nvim
-- ABOUT : Focused UI quality-of-life modules for dashboard, terminal, input, scroll, and statuscolumn.
-- LINKS :
--   > github : https://github.com/folke/snacks.nvim
-- ================================================================================================

local ghostty_dashboard = require("ui.ghostty_dashboard")

local function setup_lsp_rename(snacks)
	local rename = snacks.rename

	-- Snacks 2.x still uses the deprecated dot-call LSP compatibility wrappers
	-- and a short timeout. Keep its prompt/file handling while making the LSP
	-- hand-off reliable on a cold TypeScript project and clean on Neovim 0.13.
	rename.on_rename_file = function(from, to, rename_file)
		local changes = {
			files = {
				{
					oldUri = vim.uri_from_fname(from),
					newUri = vim.uri_from_fname(to),
				},
			},
		}
		local applied = {}

		for _, client in ipairs(vim.lsp.get_clients()) do
			if client:supports_method("workspace/willRenameFiles", 0) then
				local response = client:request_sync("workspace/willRenameFiles", changes, 5000, 0)
				if response and response.result then
					local key = vim.inspect(response.result)
					if not applied[key] then
						applied[key] = true
						vim.lsp.util.apply_workspace_edit(response.result, client.offset_encoding)
					end
				end
			end
		end

		if rename_file then
			rename_file()
		end

		for _, client in ipairs(vim.lsp.get_clients()) do
			if client:supports_method("workspace/didRenameFiles", 0) then
				client:notify("workspace/didRenameFiles", changes)
			end
		end
	end
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{
			"<leader>t",
			function()
				require("snacks.terminal")(nil, {
					cwd = vim.uv.cwd(),
				})
			end,
			desc = "Toggle terminal",
		},
		{
			"<leader>bd",
			function()
				require("snacks.bufdelete")()
			end,
			desc = "Delete buffer",
		},
		{
			"<leader>gr",
			function()
				require("snacks").rename.rename_file()
			end,
			desc = "Rename file with LSP updates",
		},
		{
			"<leader>gg",
			function()
				require("snacks").lazygit()
			end,
			desc = "Open Lazygit",
		},
		{
			"<leader>.",
			function()
				require("snacks").scratch()
			end,
			desc = "Toggle scratch buffer",
		},
		{
			"<leader>go",
			function()
				require("snacks").gitbrowse()
			end,
			mode = { "n", "x" },
			desc = "Open in Git browser",
		},
	},
	opts = {
		bigfile = {
			enabled = true,
		},
		scratch = {},
		gitbrowse = {},
		dashboard = {
			enabled = true,
			width = ghostty_dashboard.width,
			row = nil,
			pane_gap = ghostty_dashboard.pane_gap,
			preset = {
				keys = {
					{
						icon = " ",
						key = "f",
						desc = "Find File",
						action = function()
							require("fzf-lua").files()
						end,
					},
					{
						icon = " ",
						key = "n",
						desc = "New File",
						action = ":ene | startinsert",
					},
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = function()
							require("fzf-lua").live_grep()
						end,
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = function()
							require("fzf-lua").oldfiles()
						end,
					},
					{
						icon = "󰑓 ",
						key = "s",
						desc = "Restore Session",
						action = ":SessionRestore",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = function()
							require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
						end,
					},
					{
						icon = "󰒲 ",
						key = "L",
						desc = "Lazy",
						action = ":Lazy",
					},
					{
						icon = " ",
						key = "t",
						desc = "Terminal",
						action = function()
							require("snacks.terminal")(nil, { cwd = vim.uv.cwd() })
						end,
					},
					{
						icon = " ",
						key = "q",
						desc = "Quit",
						action = ":qa",
					},
				},
			},
			sections = ghostty_dashboard.sections(),
		},
		input = {
			enabled = true,
		},
		scroll = {
			enabled = true,
		},
		statuscolumn = {
			enabled = true,
		},
		terminal = {
			enabled = true,
			win = {
				border = "rounded",
			},
		},
		notifier = {
			enabled = true,
			width = { min = 40, max = 0.8 },
		},
		styles = {
			notification = {
				wo = {
					wrap = true,
					linebreak = true,
				},
			},
		},
		picker = {
			enabled = false,
		},
		explorer = {
			enabled = false,
		},
	},
	config = function(_, opts)
		local snacks = require("snacks")
		snacks.setup(opts)
		setup_lsp_rename(snacks)
		pcall(function()
			require("snacks.input").enable()
		end)
		ghostty_dashboard.setup()
	end,
}
