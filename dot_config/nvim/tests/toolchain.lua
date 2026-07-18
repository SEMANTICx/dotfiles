local failures = {}

local function fail(message)
	failures[#failures + 1] = message
	vim.api.nvim_err_writeln("[FAIL] " .. message)
end

local tools = require("config.tools")
local health_results = require("config.health").collect()
for _, result in ipairs(health_results) do
	if result.status == "ERR" then
		fail(string.format("%s: %s", result.name, result.detail or ""))
	end
end

local registry = require("mason-registry")
for _, name in ipairs(tools.mason_tools) do
	if not registry.is_installed(name) then
		fail("Mason package is not installed: " .. name)
	end
end

local installed = require("nvim-treesitter.config").get_installed("parsers")
for _, parser in ipairs(tools.treesitter_parsers) do
	if not vim.tbl_contains(installed, parser) then
		fail("Treesitter parser is not installed: " .. parser)
	end
end

local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")

local function run(name, command)
	local result = vim.system(command, { cwd = temp, text = true }):wait(30000)
	if result.code ~= 0 then
		fail(string.format("%s failed: %s", name, vim.trim(result.stderr or result.stdout or "")))
	else
		vim.api.nvim_out_write("[OK] " .. name .. "\n")
	end
end

local lua_file = vim.fs.joinpath(temp, "sample.lua")
local python_file = vim.fs.joinpath(temp, "sample.py")
local javascript_file = vim.fs.joinpath(temp, "sample.js")
local go_file = vim.fs.joinpath(temp, "sample.go")
local shell_file = vim.fs.joinpath(temp, "sample.sh")

vim.fn.writefile({ "local value = { answer = 42 }", "return value" }, lua_file)
vim.fn.writefile({ "value=42", "print(value)" }, python_file)
vim.fn.writefile({ "const value={answer:42};", "console.log(value);" }, javascript_file)
vim.fn.writefile({ "package main", "", "func main() {}" }, go_file)
vim.fn.writefile({ "#!/usr/bin/env bash", "set -euo pipefail", "echo ok" }, shell_file)

run("Stylua formatting", { "stylua", lua_file })
run("Ruff formatting", { "ruff", "format", "--quiet", python_file })
run("Ruff lint", { "ruff", "check", "--quiet", python_file })
run("Prettier formatting", { "prettier", "--write", javascript_file })
run("Gofumpt formatting", { "gofumpt", "-w", go_file })
run("Shellcheck lint", { "shellcheck", shell_file })

vim.fn.delete(temp, "rf")

if #failures > 0 then
	vim.api.nvim_err_writeln(string.format("\n%d toolchain checks failed.", #failures))
	vim.cmd("cquit 1")
else
	vim.api.nvim_out_write("\nAll toolchain checks passed.\n")
	vim.cmd("qa!")
end
