local config_dir = vim.fn.stdpath("config")
local lock_path = vim.fs.joinpath(config_dir, "lazy-lock.json")
local lock = vim.json.decode(table.concat(vim.fn.readfile(lock_path), "\n"))
local commit = assert(lock["lazy.nvim"] and lock["lazy.nvim"].commit, "lazy.nvim is missing from lazy-lock.json")
local lazy_path = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "lazy.nvim")

local function run(command, timeout)
	local result = vim.system(command, { text = true }):wait(timeout or 120000)
	assert(
		result.code == 0,
		string.format(
			"command failed (%s): %s",
			table.concat(command, " "),
			vim.trim(result.stderr or result.stdout or "")
		)
	)
	return vim.trim(result.stdout or "")
end

if vim.fn.isdirectory(vim.fs.joinpath(lazy_path, ".git")) == 0 then
	vim.fn.mkdir(vim.fs.dirname(lazy_path), "p")
	run({ "git", "clone", "--filter=blob:none", "--no-checkout", "https://github.com/folke/lazy.nvim.git", lazy_path })
end

local has_commit = vim.system({ "git", "-C", lazy_path, "cat-file", "-e", commit .. "^{commit}" }):wait().code == 0
if not has_commit then
	run({ "git", "-C", lazy_path, "fetch", "--depth=1", "origin", commit })
end

run({ "git", "-C", lazy_path, "checkout", "--detach", commit })
assert(run({ "git", "-C", lazy_path, "rev-parse", "HEAD" }) == commit, "lazy.nvim checkout does not match lockfile")
vim.api.nvim_out_write("Locked lazy.nvim bootstrap: " .. commit .. "\n")
vim.cmd("qa!")
