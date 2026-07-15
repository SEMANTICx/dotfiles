-- ================================================================================================
-- TITLE : globals
-- ABOUT : you may have different global & local leaders
-- ================================================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local statusline_backend = vim.env.NVIM_STATUSLINE or "nvchad"
if statusline_backend ~= "nvchad" and statusline_backend ~= "lualine" then
	error("NVIM_STATUSLINE must be either 'nvchad' or 'lualine'")
end
vim.g.statusline_backend = statusline_backend

-- No configured plugin uses Neovim's remote plugin hosts. External language
-- servers, formatters, linters, and Node-based tools are unaffected.
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Keep Mason-installed language tools executable without loading Mason's Lua UI/runtime.
local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
local path_separator = package.config:sub(1, 1) == "\\" and ";" or ":"
local path_entries = vim.split(vim.env.PATH or "", path_separator, { plain = true })
if not vim.tbl_contains(path_entries, mason_bin) then
	local current_path = vim.env.PATH or ""
	vim.env.PATH = current_path == "" and mason_bin or (mason_bin .. path_separator .. current_path)
end
