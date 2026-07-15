local backend = vim.g.statusline_backend
local plugins = require("lazy.core.config").plugins
local ui = assert(plugins.ui, "NvChad UI icon library is missing")
local lualine = assert(plugins["lualine.nvim"], "Lualine plugin is missing")

assert(ui._.loaded, "NvChad UI icon library did not load")
assert(require("nvim-web-devicons").get_icon("app.ts", "ts") == "󰛦", "NvChad devicons are unavailable")
assert(require("nvchad.icons.lspkind").Function == "󰆧", "NvChad LSP kind icons are unavailable")

if backend == "nvchad" then
	assert(not lualine._.loaded, "Lualine loaded on the NvChad backend")
	assert(vim.o.statusline:find("nvchad.stl.default", 1, true), "NvChad does not own the statusline")
	assert(plugins.base46 and plugins.base46._.loaded, "Base46 did not load for the NvChad statusline")
elseif backend == "lualine" then
	assert(lualine._.loaded, "Lualine did not load")
	assert(vim.o.statusline:lower():find("lualine", 1, true), "Lualine does not own the statusline")
	assert(not package.loaded["nvchad.stl.default"], "NvChad statusline renderer loaded on the Lualine backend")
	assert(not plugins.base46, "Base46 is still part of the Lualine backend")

	local source = table.concat(
		vim.fn.readfile(vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "plugins", "lualine-nvim.lua")),
		"\n"
	)
	assert(source:find('theme = "auto"', 1, true), "Lualine no longer uses theme = auto")

	local original_filetype = vim.bo.filetype
	vim.bo.filetype = "snacks_dashboard"
	local dashboard = vim.api.nvim_eval_statusline(vim.o.statusline, { winid = vim.api.nvim_get_current_win() })
	vim.bo.filetype = original_filetype
	assert(dashboard.str == "", "Lualine is visible on the Snacks dashboard")
else
	error("unexpected statusline backend: " .. tostring(backend))
end

vim.api.nvim_out_write("[OK] statusline backend: " .. backend .. "\n")
vim.cmd("qa!")
