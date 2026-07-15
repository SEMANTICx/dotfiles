-- ================================================================================================
-- TITLE : NvChad UI configuration
-- ABOUT : NvChad's statusline renderer with the layout from its early rxyhn showcase.
-- ================================================================================================

local utils = require("nvchad.stl.utils")

local FILE_BG = "#2D3139"

local function escape(value)
	return tostring(value or ""):gsub("%%", "%%%%")
end

local function statusline_buffer()
	return utils.stbufnr()
end

local icon_groups = {}

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("NvChadStatuslineFileIcons", { clear = true }),
	callback = function()
		icon_groups = {}
	end,
	desc = "Rebuild colored statusline file icons after colorscheme changes",
})

local function file()
	local bufnr = statusline_buffer()
	local path = vim.api.nvim_buf_get_name(bufnr)
	local name = path == "" and "Empty" or (path:match("([^/\\]+)[/\\]*$") or path)
	local icon = "󰈚"
	local icon_group = "St_ChadFileIcon"
	local ok, devicons = pcall(require, "nvim-web-devicons")

	if ok and path ~= "" then
		local extension = name:match("%.([^.]*)$") or ""
		local icon_value, color = devicons.get_icon_color(name, extension, { default = true })
		icon = icon_value or icon

		if color then
			icon_group = "St_ChadFileIcon" .. color:sub(2)
			if not icon_groups[icon_group] then
				vim.api.nvim_set_hl(0, icon_group, { fg = color, bg = FILE_BG })
				icon_groups[icon_group] = true
			end
		end
	end

	return "%#" .. icon_group .. "# " .. icon .. "%#St_ChadFile# " .. escape(name) .. " %#St_ChadFileSep#"
end

local function project()
	if vim.o.columns < 80 then
		return ""
	end

	local cwd = vim.uv.cwd() or vim.fn.getcwd()
	local name = cwd:match("([^/\\]+)[/\\]*$") or cwd
	return "%#St_ChadProjectOuter#%#St_ChadProjectSep#%#St_ChadProjectIcon# %#St_ChadProjectText# "
		.. escape(name)
		.. " "
end

local function git_status()
	local bufnr = statusline_buffer()
	if not vim.b[bufnr].gitsigns_head or vim.b[bufnr].gitsigns_git_status then
		return nil
	end

	return vim.b[bufnr].gitsigns_status_dict
end

local function git_diff()
	if vim.o.columns < 100 then
		return ""
	end

	local status = git_status()
	if not status then
		return ""
	end

	local added = (status.added or 0) > 0 and ("%#St_ChadGitAdd#  " .. status.added) or ""
	local changed = (status.changed or 0) > 0 and ("%#St_ChadGitChange#  " .. status.changed) or ""
	local removed = (status.removed or 0) > 0 and ("%#St_ChadGitDelete#  " .. status.removed) or ""
	return added .. changed .. removed
end

local function diagnostic_count(bufnr, severity)
	return #vim.diagnostic.get(bufnr, { severity = severity })
end

local function diagnostics()
	local bufnr = statusline_buffer()
	local values = {
		{ "St_ChadDiagnosticError", " ", diagnostic_count(bufnr, vim.diagnostic.severity.ERROR) },
		{ "St_ChadDiagnosticWarn", " ", diagnostic_count(bufnr, vim.diagnostic.severity.WARN) },
		{ "St_ChadDiagnosticHint", "󰌵 ", diagnostic_count(bufnr, vim.diagnostic.severity.HINT) },
		{ "St_ChadDiagnosticInfo", "󰋼 ", diagnostic_count(bufnr, vim.diagnostic.severity.INFO) },
	}
	local result = {}

	for _, item in ipairs(values) do
		if item[3] > 0 then
			result[#result + 1] = "%#" .. item[1] .. "# " .. item[2] .. item[3]
		end
	end

	return table.concat(result)
end

local function lsp()
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.attached_buffers[statusline_buffer()] then
			return "%#St_ChadLsp#   LSP "
		end
	end

	return ""
end

local function branch()
	if vim.o.columns < 70 then
		return ""
	end

	local status = git_status()
	if not status or not status.head or status.head == "" then
		return ""
	end

	return "%#St_ChadBranch#  " .. escape(status.head) .. " "
end

local function mode()
	if not utils.is_activewin() then
		return ""
	end

	local current = vim.api.nvim_get_mode().mode
	local value = utils.modes[current] or utils.modes[current:sub(1, 1)] or utils.modes.n
	local prefix = "St_Chad" .. value[2] .. "Mode"

	return "%#" .. prefix .. "Left# " .. value[1] .. " %#" .. prefix .. "LeftSep#"
end

local function position()
	local winid = tonumber(vim.g.statusline_winid)
	if not winid or not vim.api.nvim_win_is_valid(winid) then
		winid = vim.api.nvim_get_current_win()
	end

	local bufnr = vim.api.nvim_win_get_buf(winid)
	local line = vim.api.nvim_win_get_cursor(winid)[1]
	local total = math.max(1, vim.api.nvim_buf_line_count(bufnr))
	local text

	if line <= 1 then
		text = "Top"
	elseif line >= total then
		text = "Bot"
	else
		text = math.floor((line / total) * 100) .. "%%"
	end

	local outer = vim.o.columns >= 80 and "St_ChadPositionOuterJoined" or "St_ChadPositionOuterSolo"
	return "%#"
		.. outer
		.. "#%#St_ChadPositionSep#%#St_ChadPositionIcon# %#St_ChadPositionText# "
		.. text
		.. " "
end

return {
	base46 = {
		theme = "rxyhn",
		transparency = false,
		excluded = {
			"blankline",
			"blink",
			"cmp",
			"defaults",
			"devicons",
			"git",
			"lsp",
			"mason",
			"nvcheatsheet",
			"nvimtree",
			"syntax",
			"treesitter",
			"tbline",
			"telescope",
			"whichkey",
		},
	},
	ui = {
		statusline = {
			enabled = true,
			theme = "default",
			separator_style = "default",
			order = {
				"mode",
				"file",
				"git_diff",
				"diagnostics",
				"%=",
				"lsp",
				"branch",
				"project",
				"cursor",
			},
			modules = {
				mode = mode,
				file = file,
				project = project,
				git_diff = git_diff,
				diagnostics = diagnostics,
				lsp = lsp,
				branch = branch,
				cursor = position,
			},
		},
		tabufline = { enabled = false },
	},
	nvdash = { load_on_startup = false },
	lsp = { signature = false },
	colorify = { enabled = false },
}
