-- ================================================================================================
-- TITLE : auto-commands
-- ABOUT : automatically run code on defined events (e.g. save, yank)
-- ================================================================================================
local on_attach = require("utils.lsp").on_attach

local hover_handler = vim.lsp.handlers.hover
vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
	config = vim.tbl_deep_extend("force", { border = "rounded" }, config or {})
	return hover_handler(err, result, ctx, config)
end

local signature_help_handler = vim.lsp.handlers.signature_help
vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
	config = vim.tbl_deep_extend("force", { border = "rounded" }, config or {})
	return signature_help_handler(err, result, ctx, config)
end

-- Restore last cursor position when reopening a file
local last_cursor_group = vim.api.nvim_create_augroup("LastCursorGroup", {})
vim.api.nvim_create_autocmd("BufReadPost", {
	group = last_cursor_group,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Highlight the yanked text for 200ms
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYank", {})
vim.api.nvim_create_autocmd("TextYankPost", {
	group = highlight_yank_group,
	pattern = "*",
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch",
			timeout = 200,
		})
	end,
})

local special_filetypes = {
	bigfile = true,
	checkhealth = true,
	help = true,
	lazy = true,
	mason = true,
	oil = true,
	qf = true,
	snacks_dashboard = true,
	trouble = true,
}

-- Preserve the active fcitx5 input method across insert mode without blocking
-- Neovim's main loop. Stale callbacks are ignored when modes change quickly.
if vim.fn.executable("fcitx5-remote") == 1 then
	local fcitx_generation = 0
	local restore_fcitx = false
	local fcitx_queue = {}
	local fcitx_busy = false
	local fcitx_group = vim.api.nvim_create_augroup("Fcitx5InsertMode", { clear = true })

	local run_next
	local function enqueue(command, callback)
		fcitx_queue[#fcitx_queue + 1] = { command = command, callback = callback or function() end }
		run_next()
	end

	run_next = function()
		if fcitx_busy then
			return
		end
		local task = table.remove(fcitx_queue, 1)
		if not task then
			return
		end

		fcitx_busy = true
		vim.system(task.command, { text = true }, function(result)
			vim.schedule(function()
				fcitx_busy = false
				task.callback(result)
				run_next()
			end)
		end)
	end

	vim.api.nvim_create_autocmd("InsertLeave", {
		group = fcitx_group,
		callback = function()
			fcitx_generation = fcitx_generation + 1
			local generation = fcitx_generation

			enqueue({ "fcitx5-remote" }, function(result)
				if generation ~= fcitx_generation then
					return
				end

				restore_fcitx = result.code == 0 and tonumber(vim.trim(result.stdout or "")) == 2
				if restore_fcitx then
					enqueue({ "fcitx5-remote", "-c" })
				end
			end)
		end,
	})

	vim.api.nvim_create_autocmd("InsertEnter", {
		group = fcitx_group,
		callback = function()
			fcitx_generation = fcitx_generation + 1
			if restore_fcitx then
				restore_fcitx = false
				enqueue({ "fcitx5-remote", "-o" })
			end
		end,
	})
end

-- Render work-done progress through Neovim's native progress-message API.
local lsp_progress_group = vim.api.nvim_create_augroup("NativeLspProgress", { clear = true })
vim.api.nvim_create_autocmd("LspProgress", {
	group = lsp_progress_group,
	callback = function(event)
		local data = event.data
		local value = data and data.params and data.params.value
		if not value then
			return
		end

		local token = data.params.token or "default"
		vim.api.nvim_echo({ { value.message or value.title or "done" } }, false, {
			id = string.format("lsp.progress.%s.%s", data.client_id, token),
			kind = "progress",
			source = "vim.lsp",
			title = value.title,
			status = value.kind == "end" and "success" or "running",
			percent = value.percentage,
		})
	end,
})

local trim_disabled_filetypes = {
	gitcommit = true,
	markdown = true,
	text = true,
}

local format_disabled_filetypes = {
	gitcommit = true,
	markdown = true,
	text = true,
}

local no_swap_filetypes = vim.tbl_extend("force", {}, special_filetypes)

local function disable_swapfile_for_special_buffers(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	if vim.bo[bufnr].buftype ~= "" or no_swap_filetypes[vim.bo[bufnr].filetype] then
		vim.bo[bufnr].swapfile = false
	end
end

local function should_handle_save(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
		return false
	end
	if special_filetypes[vim.bo[bufnr].filetype] then
		return false
	end
	return true
end

local function project_disables_format(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return false
	end

	local dir = vim.fs.dirname(name)
	return #vim.fs.find(".nvim-disable-format-on-save", { path = dir, upward = true }) > 0
end

local function should_format_on_save(bufnr)
	if vim.g.format_on_save == false or vim.b[bufnr].format_on_save == false then
		return false
	end
	if format_disabled_filetypes[vim.bo[bufnr].filetype] then
		return false
	end
	return not project_disables_format(bufnr)
end

-- format on save using conform.nvim and LSP fallback
local lsp_fmt_group = vim.api.nvim_create_augroup("FormatOnSaveGroup", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	group = lsp_fmt_group,
	callback = function(args)
		if not should_handle_save(args.buf) then
			return
		end

		if
			not trim_disabled_filetypes[vim.bo[args.buf].filetype]
			and vim.b[args.buf].trim_trailing_whitespace ~= false
		then
			local ok, trailspace = pcall(require, "mini.trailspace")
			if ok then
				pcall(trailspace.trim)
			end
		end

		if not should_format_on_save(args.buf) then
			return
		end

		local ok, conform = pcall(require, "conform")
		if ok then
			conform.format({ bufnr = args.buf, timeout_ms = 2000, lsp_format = "fallback" })
		else
			vim.lsp.buf.format({ bufnr = args.buf, async = false, timeout_ms = 2000 })
		end
	end,
})

local swapfile_group = vim.api.nvim_create_augroup("SpecialBufferSwapfile", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
	group = swapfile_group,
	callback = function(args)
		disable_swapfile_for_special_buffers(args.buf)
	end,
})

-- on attach function shortcuts
local lsp_on_attach_group = vim.api.nvim_create_augroup("LspMappings", {})
vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_on_attach_group,
	callback = on_attach,
})

-- custom options for text/markdown files
local markdown_options = vim.api.nvim_create_augroup("MarkdownOptions", {})
vim.api.nvim_create_autocmd("FileType", {
	group = markdown_options,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.relativenumber = false
		vim.opt_local.number = false
		vim.opt_local.cursorline = false
		vim.opt_local.colorcolumn = ""
		vim.opt_local.signcolumn = "no"
		vim.opt_local.spell = true
	end,
})
