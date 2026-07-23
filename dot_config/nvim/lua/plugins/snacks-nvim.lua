-- ================================================================================================
-- TITLE : snacks.nvim
-- ABOUT : Focused UI quality-of-life modules for dashboard, terminal, input, scroll, and statuscolumn.
-- LINKS :
--   > github : https://github.com/folke/snacks.nvim
-- ================================================================================================

local ghostty_dashboard = require("ui.ghostty_dashboard")

local function path_exists_exact(path)
	local scan = vim.uv.fs_scandir(vim.fs.dirname(path))
	if not scan then
		return false
	end

	local basename = vim.fs.basename(path)
	while true do
		local name = vim.uv.fs_scandir_next(scan)
		if not name then
			return false
		end
		if name == basename then
			return true
		end
	end
end

local function path_belongs_to_client(client, path, bufnr)
	if bufnr and client.attached_buffers[bufnr] then
		return true
	end

	local function contains(root)
		if not root or root == "" then
			return false
		end
		return vim.fs.relpath(vim.fs.normalize(root), path) ~= nil
	end

	if contains(client.config.root_dir) then
		return true
	end

	for _, folder in ipairs(client.workspace_folders or {}) do
		local ok, root = pcall(vim.uri_to_fname, folder.uri)
		if ok and contains(root) then
			return true
		end
	end

	return false
end

local function setup_lsp_rename(snacks)
	local rename = snacks.rename

	-- Keep Snacks' prompt/file handling while limiting file-operation requests to
	-- relevant workspaces and avoiding synchronous waits on Neovim's main loop.
	rename.on_rename_file = function(from, to, rename_file)
		local from_path = vim.fs.normalize(vim.fn.fnamemodify(from, ":p"))
		local function run_rename()
			if not rename_file then
				return true
			end
			local ok, err = pcall(rename_file)
			if not ok then
				vim.notify("File rename failed: " .. tostring(err), vim.log.levels.ERROR, { title = "LSP" })
			end
			return ok
		end

		local source_existed = vim.uv.fs_lstat(from) ~= nil
		if rename_file and not source_existed then
			run_rename()
			return
		end
		local bufnr = vim.fn.bufnr(from)
		if bufnr < 1 or not vim.api.nvim_buf_is_valid(bufnr) then
			bufnr = nil
		end
		local request_bufnr = bufnr or 0
		local changes = {
			files = {
				{
					oldUri = vim.uri_from_fname(from),
					newUri = vim.uri_from_fname(to),
				},
			},
		}
		local will_rename = {}
		local did_rename = {}
		for _, client in ipairs(vim.lsp.get_clients()) do
			if path_belongs_to_client(client, from_path, bufnr) then
				if client:supports_method("workspace/willRenameFiles", request_bufnr) then
					will_rename[#will_rename + 1] = client
				end
				if client:supports_method("workspace/didRenameFiles", request_bufnr) then
					did_rename[#did_rename + 1] = client
				end
			end
		end

		local applied = {}
		local pending_requests = {}
		local pending = #will_rename
		local finished = false
		local timeout

		local function finish(timed_out)
			if finished then
				return
			end
			finished = true
			if timeout and not timeout:is_closing() then
				timeout:stop()
				timeout:close()
			end

			if timed_out then
				for request_id, client in pairs(pending_requests) do
					pcall(client.cancel_request, client, request_id)
				end
				pending_requests = {}
				vim.notify("LSP file rename preparation timed out; continuing", vim.log.levels.WARN, { title = "LSP" })
			end

			if not run_rename() then
				return
			end
			if rename_file and (path_exists_exact(from) or not path_exists_exact(to)) then
				return
			end

			for _, client in ipairs(did_rename) do
				client:notify("workspace/didRenameFiles", changes)
			end
		end

		if pending == 0 then
			finish(false)
			return
		end

		timeout = vim.defer_fn(function()
			finish(true)
		end, 5000)

		for _, client in ipairs(will_rename) do
			local lsp_client = client
			local responded = false
			local request_id
			local accepted
			accepted, request_id = lsp_client:request("workspace/willRenameFiles", changes, function(err, edit, ctx)
				responded = true
				local completed_id = (ctx and ctx.request_id) or request_id
				if completed_id then
					pending_requests[completed_id] = nil
				end
				if finished then
					return
				end
				if err then
					vim.notify(
						string.format(
							"%s could not prepare file rename: %s",
							lsp_client.name,
							err.message or vim.inspect(err)
						),
						vim.log.levels.WARN,
						{ title = "LSP" }
					)
				elseif edit then
					local key = vim.inspect(edit)
					if not applied[key] then
						applied[key] = true
						local ok, apply_err = pcall(vim.lsp.util.apply_workspace_edit, edit, lsp_client.offset_encoding)
						if not ok then
							vim.notify("Failed to apply rename edits: " .. tostring(apply_err), vim.log.levels.ERROR, {
								title = "LSP",
							})
						end
					end
				end

				pending = pending - 1
				if pending == 0 then
					finish(false)
				end
			end, request_bufnr)

			if accepted == false then
				pending = pending - 1
			elseif request_id and not responded then
				pending_requests[request_id] = lsp_client
			end
		end

		if pending == 0 then
			finish(false)
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
