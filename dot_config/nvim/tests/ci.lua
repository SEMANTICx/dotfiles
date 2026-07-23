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
check(vim.g.statusline_backend == "nvchad", "Default statusline backend is NvChad")

local lazy_config = require("lazy.core.config")
check(lazy_config.plugins["lualine.nvim"]._.loaded == nil, "Lualine stays dormant on the NvChad backend")
check(lazy_config.plugins.rustaceanvim._.loaded == nil, "Rustacean stays lazy before Rust buffers")
check(type(vim.g.rustaceanvim.dap.adapter) == "function", "Rust DAP adapter resolves lazily without loading Mason")
check(lazy_config.plugins["mason.nvim"]._.loaded == nil, "Mason stays lazy before language buffers")
local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
local path_separator = package.config:sub(1, 1) == "\\" and ";" or ":"
local path_entries = vim.split(vim.env.PATH or "", path_separator, { plain = true })
check(vim.tbl_contains(path_entries, mason_bin), "Mason tools stay on PATH while Mason is lazy")
check(lazy_config.plugins["fzf-lua"]._.loaded == nil, "FzfLua stays lazy before project selection")
check(lazy_config.plugins["mini.bufremove"] == nil, "Unused mini.bufremove removed")
check(lazy_config.plugins["nvim-transparent"] == nil, "Redundant transparency plugin removed")
for _, plugin in ipairs({ "csvview.nvim", "mini.splitjoin", "nvim-treesitter-textobjects" }) do
	check(lazy_config.plugins[plugin] ~= nil, "Workflow plugin declared: " .. plugin)
end
local lazy_key_conflicts = require("config.health").lazy_keymap_conflicts()
check(#lazy_key_conflicts == 0, "Lazy key specs avoid exact conflicts", table.concat(lazy_key_conflicts, ", "))
check(
	lazy_config.plugins["tiny-inline-diagnostic.nvim"].event == "VeryLazy",
	"Inline diagnostics load for lint-only buffers"
)

local nvchad_icons_ok, nvchad_icons_err = pcall(function()
	local devicons = require("nvim-web-devicons")
	local lspkind = require("nvchad.icons.lspkind")
	assert(devicons.get_icon("app.js", "js") == "󰌞", "JavaScript devicon override is missing")
	assert(devicons.get_icon("app.ts", "ts") == "󰛦", "TypeScript devicon override is missing")
	assert(devicons.get_icon("package.lock", "lock") == "󰌾", "lock devicon override is missing")
	assert(lspkind.Function == "󰆧" and lspkind.Variable == "󰀫", "NvChad LSP kind icons are unavailable")

	local blink_opts = lazy_config.plugins["blink.cmp"].opts
	local kind_icon = blink_opts.completion.menu.draw.components.kind_icon
	assert(kind_icon.text({ kind = "Function" }) == lspkind.Function, "Blink is not using NvChad LSP kind icons")
end)
check(nvchad_icons_ok, "NvChad devicons and LSP kind icons", nvchad_icons_err)

local undodir = vim.fs.normalize(vim.o.undodir)
local state_dir = vim.fs.normalize(vim.fn.stdpath("state"))
check(vim.startswith(undodir, state_dir), "Undo directory follows stdpath('state')", undodir)
check(vim.o.inccommand == "split", "Substitution preview uses inccommand split", vim.o.inccommand)
check(vim.o.spelllang == "en", "Configured spell dictionaries are available", vim.o.spelllang)

local function leader_prefix_conflicts(maps)
	local conflicts = {}
	for _, exact in ipairs(maps) do
		if exact.lhs:sub(1, 1) == " " then
			for _, longer in ipairs(maps) do
				if #exact.lhs < #longer.lhs and longer.lhs:sub(1, #exact.lhs) == exact.lhs then
					conflicts[#conflicts + 1] = exact.lhs .. " -> " .. longer.lhs
				end
			end
		end
	end
	return conflicts
end

local global_prefixes = leader_prefix_conflicts(vim.api.nvim_get_keymap("n"))
check(#global_prefixes == 0, "Global leader mappings avoid exact-prefix delays", table.concat(global_prefixes, ", "))
local blackhole_map = vim.fn.maparg("<leader>X", "n", false, true)
check(blackhole_map.rhs == '"_d', "Black-hole delete moved to <leader>X")
check(vim.fn.maparg("<leader>c", "n") == "", "Redundant clear-search mapping removed")

for _, command in ipairs({
	"ConfigHealth",
	"ConfigSyncTools",
	"DashboardAnimationToggle",
	"CodeCompanionCheck",
	"SessionRestore",
}) do
	check(vim.fn.exists(":" .. command) == 2, "Command available: " .. command)
end

local progress_ok, progress_err = xpcall(function()
	local ids = {}
	local original_echo = vim.api.nvim_echo
	vim.api.nvim_echo = function(_, _, opts)
		ids[#ids + 1] = opts.id
	end

	local emitted, emit_err = pcall(function()
		for _, token in ipairs({ "index", "workspace" }) do
			vim.api.nvim_exec_autocmds("LspProgress", {
				data = {
					client_id = 9,
					params = {
						token = token,
						value = { kind = "report", message = token, percentage = 10 },
					},
				},
			})
		end
	end)
	vim.api.nvim_echo = original_echo
	assert(emitted, emit_err)
	assert(#ids == 2 and ids[1] ~= ids[2], "concurrent LSP progress tokens share a message id")
end, debug.traceback)
check(progress_ok, "Concurrent LSP progress messages stay independent", progress_err)

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
check(tools.languages.python.lsp == "pyright", "Pyright remains the Python LSP")
check(contains(tools.mason_tools, "ruff"), "Ruff Mason tool declared")
check(not contains(tools.mason_tools, "black"), "Black removed from Mason tools")
check(not contains(tools.mason_tools, "flake8"), "Flake8 removed from Mason tools")
check(vim.deep_equal(tools.formatters_by_ft.python, { "ruff_format" }), "Ruff formats Python")
check(vim.deep_equal(tools.linters_by_ft.python, { "ruff" }), "Ruff lints Python")
local jsonc_formatters = tools.formatters_by_ft.jsonc or {}
check(
	jsonc_formatters[1] == "prettierd" and jsonc_formatters[2] == "prettier" and jsonc_formatters.stop_after_first,
	"JSONC uses a comment-preserving formatter"
)
check(tools.formatters_by_ft.markdown == nil, "Disabled Markdown format-on-save has no dead formatter")
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
	assert(lazy_config.plugins["mason.nvim"]._.loaded == nil, "nvim-lspconfig still loads Mason eagerly")
	local diagnostic_text = vim.diagnostic.config().signs.text
	assert(diagnostic_text[vim.diagnostic.severity.ERROR] == "󰅙", "diagnostic error icon is not from NvChad")
	assert(diagnostic_text[vim.diagnostic.severity.HINT] == "󰌵", "diagnostic hint icon is not from NvChad")

	for _, server in ipairs(tools.lsp_servers) do
		assert(vim.lsp.config[server], "missing LSP config: " .. server)
	end

	local lsp_utils = require("utils.lsp")
	local organize_imports = require("utils.organize_imports")
	local fixture_buf = vim.api.nvim_create_buf(false, true)
	local original_buf = vim.api.nvim_get_current_buf()
	local original_get_clients = vim.lsp.get_clients
	local original_get_client_by_id = vim.lsp.get_client_by_id
	local original_apply_workspace_edit = vim.lsp.util.apply_workspace_edit
	local original_conform = package.loaded.conform
	local events = {}
	local execute_callback

	local fixture_client = {
		name = "fixture_lsp",
		offset_encoding = "utf-16",
		commands = {},
		server_capabilities = {
			executeCommandProvider = { commands = { "fixture.organizeImports" } },
		},
		supports_method = function(_, method)
			return method == "textDocument/codeAction"
		end,
		request = function(_, method, params, callback)
			assert(method == "textDocument/codeAction", "unexpected fixture request: " .. method)
			assert(params.context.only[1] == "source.organizeImports", "organize imports request lost its filter")
			events[#events + 1] = "request"
			callback(nil, {
				{
					title = "Organize Imports",
					edit = { changes = {} },
					command = { title = "Organize Imports", command = "fixture.organizeImports" },
				},
			})
			return true
		end,
		exec_cmd = function(_, command, _, callback)
			assert(command.command == "fixture.organizeImports", "wrong organize imports command")
			events[#events + 1] = "command"
			execute_callback = callback
		end,
	}

	local fixture_ok, fixture_err = xpcall(function()
		vim.api.nvim_set_current_buf(fixture_buf)
		vim.lsp.get_clients = function()
			return { fixture_client }
		end
		vim.lsp.util.apply_workspace_edit = function()
			events[#events + 1] = "edit"
		end
		package.loaded.conform = {
			format = function(opts)
				assert(opts.bufnr == fixture_buf, "organize imports formatted the wrong buffer")
				events[#events + 1] = "format"
			end,
		}

		organize_imports.run(fixture_buf)
		assert(table.concat(events, ",") == "request,edit,command", "format did not wait for the LSP command")
		assert(type(execute_callback) == "function", "organize imports command callback is missing")
		execute_callback(nil)
		assert(table.concat(events, ",") == "request,edit,command,format", "organize imports callback order is wrong")

		vim.lsp.get_client_by_id = function()
			return {
				name = "fixture_lsp",
				supports_method = function()
					return false
				end,
			}
		end
		lsp_utils.on_attach({ buf = fixture_buf, data = { client_id = 1 } })
		local buffer_maps =
			vim.list_extend(vim.deepcopy(vim.api.nvim_get_keymap("n")), vim.api.nvim_buf_get_keymap(fixture_buf, "n"))
		local prefixes = leader_prefix_conflicts(buffer_maps)
		assert(#prefixes == 0, "LSP mappings contain exact-prefix delays: " .. table.concat(prefixes, ", "))
		local diagnostic_map = vim.iter(vim.api.nvim_buf_get_keymap(fixture_buf, "n")):find(function(map)
			return map.lhs == " dd"
		end)
		assert(
			diagnostic_map and diagnostic_map.desc == "Diagnostics: cursor",
			"cursor diagnostics did not move to <leader>dd"
		)
		local definition_map = vim.iter(vim.api.nvim_buf_get_keymap(fixture_buf, "n")):find(function(map)
			return map.lhs == " gd"
		end)
		assert(definition_map and definition_map.desc == "LSP: go to definition", "LSP mappings lack descriptions")
	end, debug.traceback)

	vim.lsp.get_clients = original_get_clients
	vim.lsp.get_client_by_id = original_get_client_by_id
	vim.lsp.util.apply_workspace_edit = original_apply_workspace_edit
	package.loaded.conform = original_conform
	if vim.api.nvim_buf_is_valid(original_buf) then
		vim.api.nvim_set_current_buf(original_buf)
	end
	if vim.api.nvim_buf_is_valid(fixture_buf) then
		vim.api.nvim_buf_delete(fixture_buf, { force = true })
	end
	assert(fixture_ok, fixture_err)

	local gopls = assert(vim.lsp.config.gopls)
	for _, filetype in ipairs({ "go", "gomod", "gowork", "gotmpl" }) do
		assert(contains(gopls.filetypes, filetype), "gopls missing filetype: " .. filetype)
	end

	local tailwind = assert(vim.lsp.config.tailwindcss)
	for _, filetype in ipairs({ "html", "css", "scss", "typescriptreact" }) do
		assert(contains(tailwind.filetypes, filetype), "tailwindcss missing filetype: " .. filetype)
	end
	assert(type(tailwind.root_dir) == "function", "tailwindcss root_dir must support v4 discovery")

	local tinymist = assert(vim.lsp.config.tinymist)
	assert(type(tinymist.on_attach) == "function", "tinymist on_attach is unavailable")
	local typst_buf = vim.api.nvim_create_buf(false, true)
	local typst_path = vim.fs.joinpath(vim.fn.tempname(), "main.typ")
	vim.api.nvim_buf_set_name(typst_buf, typst_path)
	local exports = {}
	tinymist.on_attach({
		request = function() end,
		exec_cmd = function(_, command, context)
			exports[#exports + 1] = { command = command, context = context }
		end,
	}, typst_buf)
	local typst_commands = vim.api.nvim_buf_get_commands(typst_buf, {})
	for _, format in ipairs({ "PDF", "SVG", "PNG", "HTML", "Markdown" }) do
		local name = "TypstExport" .. format
		assert(typst_commands[name], "missing buffer command: " .. name)
		vim.api.nvim_buf_call(typst_buf, function()
			vim.cmd(name)
		end)
	end
	assert(typst_commands.TypstOpenPDF, "missing buffer command: TypstOpenPDF")
	assert(#exports == 5, string.format("expected five Typst exports, got %d", #exports))
	for _, call in ipairs(exports) do
		assert(call.command.arguments[1] == typst_path, "Typst export used the wrong source path")
		assert(call.context.bufnr == typst_buf, "Typst export used the wrong buffer")
	end
	vim.api.nvim_buf_delete(typst_buf, { force = true })

	local yaml_schemas = assert(vim.lsp.config.yamlls.settings.yaml.schemas)
	local compose_patterns = assert(yaml_schemas["https://json.schemastore.org/docker-compose.json"])
	for _, pattern in ipairs({ "docker-compose*.yml", "docker-compose*.yaml", "compose.yml", "compose.yaml" }) do
		assert(contains(compose_patterns, pattern), "Docker Compose schema misses: " .. pattern)
	end
	assert(yaml_schemas["https://json.schemastore.org/composer.json"] == nil, "yamlls contains a JSON-only schema")

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

local snacks_rename_ok, snacks_rename_err = xpcall(function()
	local rename = require("snacks").rename
	local original_get_clients = vim.lsp.get_clients
	local original_apply_workspace_edit = vim.lsp.util.apply_workspace_edit
	local original_defer_fn = vim.defer_fn
	local temp = vim.fn.tempname()
	vim.fn.mkdir(temp, "p")
	local from = vim.fs.joinpath(temp, "old.ts")
	local to = vim.fs.joinpath(temp, "new.ts")
	vim.fn.writefile({ "export const value = 1" }, from)
	local request_callback
	local request_id = 40
	local applied = false
	local notified = false
	local cancelled

	local relevant_client = {
		name = "relevant",
		config = { root_dir = temp },
		attached_buffers = {},
		offset_encoding = "utf-16",
		supports_method = function()
			return true
		end,
		request = function(_, method, _, callback)
			assert(method == "workspace/willRenameFiles")
			request_callback = callback
			request_id = request_id + 1
			return true, request_id
		end,
		cancel_request = function(_, id)
			cancelled = id
		end,
		notify = function(_, method)
			assert(method == "workspace/didRenameFiles")
			notified = true
		end,
	}
	local irrelevant_client = {
		name = "irrelevant",
		config = { root_dir = temp .. "-other" },
		attached_buffers = {},
		supports_method = function()
			return true
		end,
		request = function()
			error("irrelevant LSP client received a rename request")
		end,
		notify = function()
			error("irrelevant LSP client received a rename notification")
		end,
	}

	local fixture_ok, fixture_err = xpcall(function()
		vim.lsp.get_clients = function()
			return { relevant_client, irrelevant_client }
		end
		vim.lsp.util.apply_workspace_edit = function()
			applied = true
		end

		rename.rename_file({ from = from, to = to })
		assert(type(request_callback) == "function", "relevant LSP client did not receive a rename request")
		assert(vim.fn.filereadable(from) == 1, "file rename did not wait for the LSP response")
		request_callback(nil, { changes = {} })
		assert(
			vim.fn.filereadable(from) == 0 and vim.fn.filereadable(to) == 1 and applied and notified,
			"asynchronous rename sequence did not complete"
		)

		request_callback = nil
		notified = false
		local failed_from = vim.fs.joinpath(temp, "failed-old.ts")
		local failed_to = vim.fs.joinpath(temp, "failed-new.ts")
		vim.fn.writefile({ "export const failed = true" }, failed_from)
		rename.on_rename_file(failed_from, failed_to, function() end)
		assert(type(request_callback) == "function", "post-request rename failure did not reach LSP preparation")
		request_callback(nil, nil)
		assert(
			vim.fn.filereadable(failed_from) == 1 and vim.fn.filereadable(failed_to) == 0 and not notified,
			"post-request file rename failure notified LSP clients"
		)

		request_callback = nil
		notified = false
		rename.rename_file({
			from = vim.fs.joinpath(temp, "missing.ts"),
			to = vim.fs.joinpath(temp, "still-missing.ts"),
		})
		assert(request_callback == nil and not notified, "failed file rename notified LSP clients")

		local timeout_callback
		local timeout_from = vim.fs.joinpath(temp, "timeout-old.ts")
		local timeout_to = vim.fs.joinpath(temp, "timeout-new.ts")
		vim.fn.writefile({ "export const timeout = true" }, timeout_from)
		vim.defer_fn = function(callback)
			timeout_callback = callback
			return {
				is_closing = function()
					return false
				end,
				stop = function() end,
				close = function() end,
			}
		end
		rename.on_rename_file(timeout_from, timeout_to, function() end)
		local timed_out_request = request_id
		assert(type(timeout_callback) == "function", "rename timeout was not scheduled")
		timeout_callback()
		assert(cancelled == timed_out_request, "timed-out LSP rename request was not cancelled")
	end, debug.traceback)

	vim.lsp.get_clients = original_get_clients
	vim.lsp.util.apply_workspace_edit = original_apply_workspace_edit
	vim.defer_fn = original_defer_fn
	vim.fn.delete(temp, "rf")
	assert(fixture_ok, fixture_err)
end, debug.traceback)
check(snacks_rename_ok, "Snacks file rename is asynchronous, scoped, and failure-safe", snacks_rename_err)

local session_ok, session_err = pcall(function()
	local startup_restores = vim.api.nvim_get_autocmds({
		group = "ProjectDirSessions",
		event = "VimEnter",
	})
	assert(#startup_restores == 0, "plain Neovim startup must leave the dashboard visible")
	local exit_saves = vim.api.nvim_get_autocmds({
		group = "ProjectDirSessions",
		event = "VimLeavePre",
	})
	assert(#exit_saves == 1, "project session exit save is unavailable")
	require("resession").get_current()
	local resession_config = require("resession.config")
	assert(
		resession_config.autosave.enabled and resession_config.autosave.interval == 120,
		"periodic project session checkpoints are unavailable"
	)
	local duplicate_saves = vim.api.nvim_get_autocmds({
		group = "ResessionAutosave",
		event = "VimLeavePre",
	})
	assert(#duplicate_saves == 0, "Resession registered a duplicate exit save")
end)
check(session_ok, "Project sessions do not replace the startup dashboard", session_err)

local statusline_ok, statusline_err = pcall(function()
	local renderer = require("nvchad.stl.default")
	local source = debug.getinfo(renderer, "S").source
	assert(source:find("/lazy/ui/", 1, true), "statusline renderer is not loaded from NvChad/ui: " .. source)
	vim.cmd.colorscheme("duskfox")
	vim.wait(100)

	assert(vim.api.nvim_get_hl(0, { name = "Normal" }).bg == nil, "Normal background is no longer transparent")
	assert(
		vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg == nil,
		"NormalFloat background is no longer transparent"
	)
	assert(
		vim.api.nvim_get_hl(0, { name = "NvimTreeNormal" }).bg == nil,
		"NvimTree background is no longer transparent"
	)
	assert(vim.api.nvim_get_hl(0, { name = "NvimTreeNormalNC" }).bg == nil, "inactive NvimTree background is opaque")
	assert(vim.api.nvim_get_hl(0, { name = "NvimTreeEndOfBuffer" }).bg == nil, "NvimTree end area is opaque")
	assert(
		vim.api.nvim_get_hl(0, { name = "NvimTreeCursorLine" }).bg == tonumber("282C34", 16),
		"wrong soft NvimTree cursor background"
	)
	assert(vim.api.nvim_get_hl(0, { name = "StatusLine" }).bg == tonumber("22262E", 16), "wrong statusline background")
	assert(vim.api.nvim_get_hl(0, { name = "St_ChadFile" }).bg == tonumber("2D3139", 16), "wrong file background")
	assert(vim.api.nvim_get_hl(0, { name = "St_ChadProjectIcon" }).bg == tonumber("E06C75", 16), "wrong project accent")
	assert(
		vim.api.nvim_get_hl(0, { name = "St_ChadNormalModeLeft" }).bg == tonumber("81A1C1", 16),
		"wrong screenshot-derived normal color"
	)
	assert(
		vim.api.nvim_get_hl(0, { name = "St_ChadInsertModeLeft" }).bg == tonumber("98C379", 16),
		"wrong insert color"
	)
	assert(
		vim.api.nvim_get_hl(0, { name = "St_ChadPositionIcon" }).bg == tonumber("98C379", 16),
		"wrong position color"
	)
	assert(
		vim.api.nvim_get_hl(0, { name = "St_ChadProjectOuter" }).fg == tonumber("343A44", 16),
		"wrong project outer curve color"
	)
	assert(
		vim.api.nvim_get_hl(0, { name = "St_ChadProjectText" }).bg == tonumber("2D3139", 16),
		"wrong project background color"
	)
	assert(
		vim.api.nvim_get_hl(0, { name = "St_ChadPositionOuterJoined" }).fg == tonumber("3B414B", 16),
		"wrong position outer curve color"
	)
	assert(
		vim.api.nvim_get_hl(0, { name = "St_ChadPositionText" }).bg == tonumber("2D3139", 16),
		"wrong position text background"
	)

	local modules = require("nvconfig").ui.statusline.modules
	local bufnr = vim.api.nvim_get_current_buf()
	local old_columns = vim.o.columns
	local old_winid = vim.g.statusline_winid
	local old_head = vim.b[bufnr].gitsigns_head
	local old_status = vim.b[bufnr].gitsigns_status_dict
	local diagnostic_ns = vim.api.nvim_create_namespace("StatuslineRegression")
	local mocked_diagnostics = {}

	local function add_diagnostics(severity, count)
		for _ = 1, count do
			mocked_diagnostics[#mocked_diagnostics + 1] = {
				lnum = 0,
				col = 0,
				message = "statusline fixture",
				severity = severity,
			}
		end
	end

	add_diagnostics(vim.diagnostic.severity.ERROR, 24)
	add_diagnostics(vim.diagnostic.severity.WARN, 1)
	add_diagnostics(vim.diagnostic.severity.HINT, 2)

	vim.g.statusline_winid = vim.api.nvim_get_current_win()
	vim.b[bufnr].gitsigns_head = "main"
	vim.b[bufnr].gitsigns_status_dict = { head = "main", added = 3, changed = 0, removed = 1 }
	vim.diagnostic.set(diagnostic_ns, bufnr, mocked_diagnostics)

	local fixture_ok, fixture_err = xpcall(function()
		vim.g.statusline_winid = vim.api.nvim_get_current_win()
		vim.o.columns = 169
		local wide = renderer()
		for _, text in ipairs({ "NORMAL", " 3", " 1", " 24", " 1", "󰌵 2", " main", "", "Top" }) do
			assert(wide:find(text, 1, true), "wide statusline is missing " .. text)
		end
		assert(modules.file():find("St_ChadFileSep#", 1, true), "file block does not end with a rounded separator")
		assert(not wide:find("", 1, true), "wide statusline still contains the old logo")
		assert(not wide:find("", 1, true), "mode still contains an icon")
		assert(
			modules.project():find("St_ChadProjectOuter#%#St_ChadProjectSep#", 1, true),
			"project block is missing the dark and colored left curves"
		)
		assert(
			modules.project():find("St_ChadProjectIcon# ", 1, true),
			"project icon block does not match the compact NvChad ratio"
		)
		assert(
			modules.cursor():find("St_ChadPositionOuterJoined#%#St_ChadPositionSep#", 1, true),
			"position block is missing the joined dark and colored left curves"
		)
		assert(
			modules.cursor():find("St_ChadPositionIcon# ", 1, true),
			"position icon block does not match the compact NvChad ratio"
		)
		assert(not wide:find("St_ChadRightCap", 1, true), "right modules still contain the misplaced dark cap")
		local branch_at = assert(wide:find(" main", 1, true))
		local project_at = assert(wide:find("", 1, true))
		local position_at = assert(wide:find("Top", 1, true))
		assert(branch_at < project_at and project_at < position_at, "project is not in the former right-side mode slot")

		vim.o.columns = 84
		local medium = renderer()
		assert(not medium:find(" 3", 1, true), "medium statusline did not hide Git diff")
		assert(medium:find(" main", 1, true), "medium statusline hid the branch too early")

		vim.o.columns = 60
		local narrow = renderer()
		assert(not narrow:find("", 1, true), "narrow statusline did not hide the project")
		assert(not narrow:find(" main", 1, true), "narrow statusline did not hide the branch")
		assert(
			narrow:find("St_ChadPositionOuterSolo#", 1, true),
			"narrow position block did not switch to the standalone outer curve"
		)
	end, debug.traceback)

	vim.diagnostic.reset(diagnostic_ns, bufnr)
	vim.b[bufnr].gitsigns_head = old_head
	vim.b[bufnr].gitsigns_status_dict = old_status
	vim.g.statusline_winid = old_winid
	vim.o.columns = old_columns
	assert(fixture_ok, fixture_err)
end)
check(statusline_ok, "NvChad statusline palette, modules, and responsive layout", statusline_err)

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

local fcitx_ok, fcitx_err = xpcall(function()
	local original_executable = vim.fn.executable
	local original_system = vim.system
	local calls = {}
	local callbacks = {}

	local fixture_ok, fixture_err = xpcall(function()
		vim.fn.executable = function(command)
			if command == "fcitx5-remote" then
				return 1
			end
			return original_executable(command)
		end
		vim.system = function(command, opts, callback)
			if command[1] ~= "fcitx5-remote" then
				return original_system(command, opts, callback)
			end
			calls[#calls + 1] = command[2] or "query"
			callbacks[#callbacks + 1] = callback
			return {}
		end

		dofile(vim.fn.stdpath("config") .. "/lua/config/autocmds.lua")
		vim.api.nvim_exec_autocmds("InsertLeave", { group = "Fcitx5InsertMode" })
		assert(calls[1] == "query", "fcitx state query was not queued")
		callbacks[1]({ code = 0, stdout = "2\n" })
		assert(
			vim.wait(1000, function()
				return calls[2] == "-c"
			end),
			"fcitx close was not queued"
		)

		vim.api.nvim_exec_autocmds("InsertEnter", { group = "Fcitx5InsertMode" })
		assert(#calls == 2, "fcitx reopen raced ahead of the pending close")
		callbacks[2]({ code = 0, stdout = "" })
		assert(
			vim.wait(1000, function()
				return calls[3] == "-o"
			end),
			"fcitx reopen did not wait for close completion"
		)
		callbacks[3]({ code = 0, stdout = "" })
	end, debug.traceback)

	vim.fn.executable = original_executable
	vim.system = original_system
	assert(fixture_ok, fixture_err)
end, debug.traceback)
check(fcitx_ok, "Fcitx mode transitions serialize close and reopen commands", fcitx_err)

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
