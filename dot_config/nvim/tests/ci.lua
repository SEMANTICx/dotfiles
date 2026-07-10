local failures = {}
local checks = 0

local function check(condition, name, detail)
	checks = checks + 1
	if condition then
		vim.api.nvim_out_write(string.format("[OK] %s\n", name))
		return
	end

	failures[#failures + 1] = detail and string.format("%s: %s", name, detail) or name
	vim.api.nvim_err_writeln(string.format("[FAIL] %s%s", name, detail and ": " .. detail or ""))
end

local function contains(list, value)
	return vim.tbl_contains(list or {}, value)
end

local function report_github_error(messages)
	if vim.env.GITHUB_ACTIONS ~= "true" then
		return
	end

	local detail = table.concat(messages, "\n"):gsub("%%", "%%25"):gsub("\r", "%%0D"):gsub("\n", "%%0A")
	vim.api.nvim_out_write("::error title=Neovim regression::" .. detail .. "\n")
end

local config_dir = vim.fn.stdpath("config")
local lua_files = vim.fn.globpath(config_dir, "lua/**/*.lua", false, true)
lua_files[#lua_files + 1] = vim.fs.joinpath(config_dir, "init.lua")
vim.list_extend(lua_files, vim.fn.globpath(config_dir, "tests/*.lua", false, true))

for _, path in ipairs(lua_files) do
	local chunk, err = loadfile(path)
	check(chunk ~= nil, "Lua syntax: " .. vim.fn.fnamemodify(path, ":."), err)
end

local lazy = require("lazy")
local stats = lazy.stats()
check(stats.count >= 45, "Lazy plugin spec", string.format("expected at least 45 plugins, got %d", stats.count))

local lazy_config = require("lazy.core.config")
check(lazy_config.plugins.rustaceanvim._.loaded == nil, "Rustacean stays lazy before Rust buffers")
check(
	type(vim.g.rustaceanvim.dap.adapter) == "function",
	"Rust DAP adapter resolves lazily without loading Mason"
)
check(lazy_config.plugins["mason.nvim"]._.loaded == nil, "Mason stays lazy before language buffers")
check(lazy_config.plugins["mini.bufremove"] == nil, "Unused mini.bufremove removed")
check(lazy_config.plugins["nvim-transparent"] == nil, "Redundant transparency plugin removed")

local undodir = vim.fs.normalize(vim.o.undodir)
local state_dir = vim.fs.normalize(vim.fn.stdpath("state"))
check(vim.startswith(undodir, state_dir), "Undo directory follows stdpath('state')", undodir)

for _, command in ipairs({ "ConfigHealth", "ConfigSyncTools", "DashboardAnimationToggle", "CodeCompanionCheck" }) do
	check(vim.fn.exists(":" .. command) == 2, "Command available: " .. command)
end

for _, provider in ipairs({ "node", "python3", "ruby", "perl" }) do
	check(vim.g["loaded_" .. provider .. "_provider"] == 0, "Remote provider disabled: " .. provider)
end

local tools = require("config.tools")
local ordered = {}
for _, name in ipairs(tools.language_order) do
	check(not ordered[name], "Unique language entry: " .. name)
	ordered[name] = true
	check(type(tools.languages[name]) == "table", "Language definition: " .. name)
end
check(contains(tools.treesitter_parsers, "tsx"), "TSX parser declared")

local treesitter_ok, treesitter_err = pcall(function()
	lazy.load({ plugins = { "nvim-treesitter" } })
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "const App = () => <main>Hello</main>" })
	vim.bo[buf].filetype = "typescriptreact"
	local parser_files = vim.api.nvim_get_runtime_file("parser/tsx.*", false)
	local language_ok, language_result = pcall(vim.treesitter.language.add, "tsx")
	assert(
		language_ok and language_result,
		string.format(
			"TSX language load failed on Neovim %s: %s; parser files: %s",
			vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
			language_ok and vim.inspect(language_result) or language_result,
			vim.inspect(parser_files)
		)
	)
	local parser, parser_err = vim.treesitter.get_parser(buf, "tsx")
	assert(parser, parser_err or "TSX parser is unavailable")
	parser:parse()
	vim.api.nvim_buf_delete(buf, { force = true })
end)
check(treesitter_ok, "TSX parser loads and parses", treesitter_err)

local lsp_ok, lsp_err = pcall(function()
	lazy.load({ plugins = { "nvim-lspconfig" } })
	for _, server in ipairs(tools.lsp_servers) do
		assert(vim.lsp.config[server], "missing LSP config: " .. server)
	end

	local tailwind = assert(vim.lsp.config.tailwindcss)
	for _, filetype in ipairs({ "html", "css", "scss", "typescriptreact" }) do
		assert(contains(tailwind.filetypes, filetype), "tailwindcss missing filetype: " .. filetype)
	end
	assert(type(tailwind.root_dir) == "function", "tailwindcss root_dir must support v4 discovery")

	local temp = vim.fn.tempname()
	vim.fn.mkdir(vim.fs.joinpath(temp, ".git"), "p")
	local plain_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(plain_buf, vim.fs.joinpath(temp, "plain.html"))
	vim.bo[plain_buf].filetype = "html"
	local plain_root
	tailwind.root_dir(plain_buf, function(root)
		plain_root = root
	end)
	assert(plain_root == nil, "tailwindcss attached to a Git repo without Tailwind")

	vim.fn.writefile({ '{"devDependencies":{"tailwindcss":"^4.0.0"}}' }, vim.fs.joinpath(temp, "package.json"))
	local package_root
	tailwind.root_dir(plain_buf, function(root)
		package_root = root
	end)
	assert(vim.fs.normalize(package_root) == vim.fs.normalize(temp), "tailwindcss missed package.json dependency")

	vim.api.nvim_buf_delete(plain_buf, { force = true })
	vim.fn.delete(temp, "rf")
end)
check(lsp_ok, "LSP configuration and Tailwind coverage", lsp_err)

local dashboard_ok, dashboard_err = pcall(function()
	local dashboard = require("ui.ghostty_dashboard")
	local section = dashboard.sections()[1]
	local context = { _size = { width = 80 }, opts = {} }
	local wide = section(context)
	local wide_width = context.opts.width
	context._size.width = 40
	local narrow = section(context)
	assert(type(wide.header) == "string" and wide.header ~= "", "wide dashboard header is empty")
	assert(type(narrow.header) == "string" and narrow.header ~= "", "narrow dashboard header is empty")
	assert(context.opts.width < wide_width, "dashboard width did not respond to resize")
	assert(
		#vim.api.nvim_get_autocmds({ group = "GhostyDashboardAnimation", event = "FocusLost" }) == 1,
		"dashboard FocusLost pause autocmd is missing"
	)
	assert(
		#vim.api.nvim_get_autocmds({ group = "GhostyDashboardAnimation", event = "FocusGained" }) == 1,
		"dashboard FocusGained resume autocmd is missing"
	)
end)
check(dashboard_ok, "Dashboard assets and responsive layout", dashboard_err)

local lint_ok, lint_err = pcall(function()
	vim.g.lint_debounce_ms = 30
	local buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_set_current_buf(buf)
	vim.bo[buf].filetype = "python"
	lazy.load({ plugins = { "nvim-lint" } })
	vim.wait(80)

	local lint = require("lint")
	local original_try_lint = lint.try_lint
	local calls = 0
	lint.linters_by_ft.python = { "sh" }
	lint.try_lint = function()
		calls = calls + 1
	end

	for _ = 1, 3 do
		vim.api.nvim_exec_autocmds("InsertLeave", { buffer = buf, modeline = false })
	end
	vim.wait(150)
	assert(calls == 1, string.format("expected one debounced lint, got %d", calls))

	calls = 0
	vim.api.nvim_exec_autocmds("InsertLeave", { buffer = buf, modeline = false })
	vim.api.nvim_exec_autocmds("BufWritePost", { buffer = buf, modeline = false })
	vim.wait(150)
	assert(calls == 1, string.format("save did not cancel pending lint; got %d calls", calls))

	lint.try_lint = original_try_lint
	vim.api.nvim_buf_delete(buf, { force = true })
end)
check(lint_ok, "Lint debounce and save cancellation", lint_err)

if #failures > 0 then
	report_github_error(failures)
	vim.api.nvim_err_writeln(string.format("\n%d/%d regression checks failed:", #failures, checks))
	for _, failure in ipairs(failures) do
		vim.api.nvim_err_writeln("- " .. failure)
	end
	vim.cmd("cquit 1")
else
	vim.api.nvim_out_write(string.format("\nAll %d regression checks passed.\n", checks))
	vim.cmd("qa!")
end
