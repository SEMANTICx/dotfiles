local session_dir = "dirsession"

local function session_names(resession)
	local names = {}
	for _, name in ipairs(resession.list({ dir = session_dir })) do
		names[name] = true
	end
	return names
end

local function modified_buffers()
	local names = {}
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted and vim.bo[bufnr].modified then
			local name = vim.api.nvim_buf_get_name(bufnr)
			table.insert(names, name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]")
		end
	end
	return names
end

local function has_meaningful_buffer()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
			local filetype = vim.bo[bufnr].filetype
			local name = vim.api.nvim_buf_get_name(bufnr)
			if vim.bo[bufnr].modified or name ~= "" or (filetype ~= "" and filetype ~= "snacks_dashboard") then
				return true
			end
		end
	end
	return false
end

local function restore_current_project()
	local resession = require("resession")
	local cwd = vim.fs.normalize(vim.fn.getcwd())
	if not session_names(resession)[cwd] then
		vim.notify("No saved session for: " .. cwd, vim.log.levels.INFO)
		return
	end
	resession.load(cwd, { dir = session_dir, reset = true, silence_errors = false })
end

local function reset_workspace(resession)
	resession.detach()
	local old_buffers = vim.api.nvim_list_bufs()
	vim.cmd("silent! tabonly")
	vim.cmd("silent! only")
	vim.cmd("enew")
	local current = vim.api.nvim_get_current_buf()
	for _, bufnr in ipairs(old_buffers) do
		if bufnr ~= current and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
			pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
		end
	end
end

local function switch_project(path)
	path = vim.fs.normalize(path)
	if not vim.uv.fs_stat(path) then
		vim.notify("Project directory no longer exists: " .. path, vim.log.levels.ERROR)
		return
	end

	local dirty = modified_buffers()
	if #dirty > 0 then
		vim.notify(
			"Save modified buffers before switching projects:\n" .. table.concat(dirty, "\n"),
			vim.log.levels.WARN
		)
		return
	end

	local resession = require("resession")
	local current = vim.fs.normalize(vim.fn.getcwd())
	resession.save(current, { dir = session_dir, notify = false })
	vim.api.nvim_set_current_dir(path)

	if session_names(resession)[path] then
		resession.load(path, { dir = session_dir, reset = true, silence_errors = true })
	else
		reset_workspace(resession)
	end

	vim.system({ "zoxide", "add", path }, { detach = true })
	vim.notify("Project: " .. path, vim.log.levels.INFO)
end

local function pick_project()
	local result = vim.system({ "zoxide", "query", "--list" }, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify("zoxide query failed: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
		return
	end

	local projects = vim.split(vim.trim(result.stdout or ""), "\n", { trimempty = true })
	if #projects == 0 then
		vim.notify("zoxide has no project directories yet", vim.log.levels.WARN)
		return
	end

	require("lazy").load({ plugins = { "fzf-lua" } })
	require("fzf-lua").fzf_exec(projects, {
		prompt = "Projects> ",
		previewer = false,
		actions = {
			["default"] = function(selected)
				if selected[1] then
					switch_project(selected[1])
				end
			end,
		},
	})
end

return {
	"stevearc/resession.nvim",
	lazy = false,
	cond = not vim.g.vscode,
	keys = {
		{ "<leader>fz", pick_project, desc = "Switch project (zoxide + session)" },
		{ "<leader>sr", restore_current_project, desc = "Restore current project session" },
		{
			"<leader>ss",
			function()
				require("resession").save(vim.fs.normalize(vim.fn.getcwd()), { dir = session_dir })
			end,
			desc = "Save project session",
		},
	},
	config = function()
		local resession = require("resession")
		resession.setup({ autosave = { enabled = true, interval = 120, notify = false } })
		vim.api.nvim_create_user_command("SessionRestore", restore_current_project, {
			desc = "Restore the saved session for the current project",
		})

		local group = vim.api.nvim_create_augroup("ProjectDirSessions", { clear = true })
		vim.api.nvim_create_autocmd("StdinReadPre", {
			group = group,
			callback = function()
				vim.g.using_stdin = true
			end,
		})
		vim.api.nvim_create_autocmd("VimLeavePre", {
			group = group,
			callback = function()
				if vim.env.CI ~= "true" and not vim.g.using_stdin and has_meaningful_buffer() then
					local cwd = vim.fs.normalize(vim.fn.getcwd())
					resession.save(cwd, { dir = session_dir, notify = false })
				end
			end,
		})
	end,
}
