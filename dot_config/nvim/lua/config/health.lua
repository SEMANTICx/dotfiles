local M = {}

local function add(results, status, name, detail)
	results[#results + 1] = {
		status = status,
		name = name,
		detail = detail,
	}
end

local function flatten_tools(formatters_by_ft, linters_by_ft, linter_commands)
	local tools = {}
	local seen = {}

	local function add_tool(tool)
		if type(tool) ~= "string" or seen[tool] then
			return
		end
		seen[tool] = true
		tools[#tools + 1] = linter_commands[tool] or tool:gsub("_", "-")
	end

	for _, formatters in pairs(formatters_by_ft) do
		for _, formatter in ipairs(formatters) do
			add_tool(formatter)
		end
	end
	for _, linters in pairs(linters_by_ft) do
		for _, linter in ipairs(linters) do
			add_tool(linter)
		end
	end

	table.sort(tools)
	return tools
end

local function command_exists(command)
	return vim.fn.exists(":" .. command) == 2
end

local function global_core_keymaps()
	local found = {}
	for _, map in ipairs(vim.api.nvim_get_keymap("n")) do
		if map.lhs == ":" or map.lhs == "/" or map.lhs == "?" then
			found[#found + 1] = map.lhs
		end
	end
	table.sort(found)
	return found
end

local function duplicate_keymaps()
	local seen = {}
	local duplicates = {}

	for _, mode in ipairs({ "n", "v", "x", "i", "c", "t", "o" }) do
		for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
			local key = mode .. "\t" .. map.lhs
			if seen[key] then
				duplicates[#duplicates + 1] = key
			else
				seen[key] = true
			end
		end
	end

	table.sort(duplicates)
	return duplicates
end

local function dashboard_frame_count()
	local dir = vim.fn.stdpath("config") .. "/assets/ghostty-animation"
	return #vim.fn.globpath(dir, "frame_*.txt", false, true)
end

local function validate_string_list(issues, value, label)
	if value == nil then
		return
	end
	if type(value) ~= "table" then
		issues[#issues + 1] = label .. " must be a table"
		return
	end
	for index, item in ipairs(value) do
		if type(item) ~= "string" then
			issues[#issues + 1] = string.format("%s[%d] must be a string", label, index)
		end
	end
end

local function validate_by_filetype(issues, value, label)
	if value == nil then
		return
	end
	if type(value) ~= "table" then
		issues[#issues + 1] = label .. " must be a table"
		return
	end
	for filetype, list in pairs(value) do
		if type(filetype) ~= "string" then
			issues[#issues + 1] = label .. " filetype keys must be strings"
		end
		validate_string_list(issues, list, label .. "." .. tostring(filetype))
	end
end

local function check_tools_schema(results, tools)
	local errors = {}
	local warnings = {}
	local ordered = {}

	if type(tools.language_order) ~= "table" then
		errors[#errors + 1] = "language_order must be a table"
	end
	if type(tools.languages) ~= "table" then
		errors[#errors + 1] = "languages must be a table"
	end
	if #errors > 0 then
		add(results, "ERR", "tools schema", table.concat(errors, "; "))
		return
	end

	for index, name in ipairs(tools.language_order) do
		if type(name) ~= "string" then
			errors[#errors + 1] = string.format("language_order[%d] must be a string", index)
		elseif ordered[name] then
			warnings[#warnings + 1] = "duplicate language_order entry: " .. name
		elseif not tools.languages[name] then
			errors[#errors + 1] = "language_order references missing language: " .. name
		else
			ordered[name] = true
		end
	end

	for name, language in pairs(tools.languages) do
		if not ordered[name] then
			warnings[#warnings + 1] = "language not listed in language_order: " .. name
		end
		if type(language) ~= "table" then
			errors[#errors + 1] = "language must be a table: " .. name
		else
			if language.lsp ~= nil and type(language.lsp) ~= "string" then
				errors[#errors + 1] = name .. ".lsp must be a string"
			end
			validate_string_list(errors, language.mason, name .. ".mason")
			validate_string_list(errors, language.treesitter, name .. ".treesitter")
			validate_by_filetype(errors, language.formatters, name .. ".formatters")
			validate_by_filetype(errors, language.linters, name .. ".linters")
		end
	end

	if #errors > 0 then
		add(results, "ERR", "tools schema", table.concat(errors, "; "))
	elseif #warnings > 0 then
		add(results, "WARN", "tools schema", table.concat(warnings, "; "))
	else
		add(results, "OK", "tools schema", "language_order and language definitions are consistent")
	end
end

local function missing_mason_tools(tools)
	local ok, registry = pcall(require, "mason-registry")
	if not ok then
		return nil, "mason-registry unavailable"
	end

	local missing = {}
	for _, tool in ipairs(tools) do
		if not registry.is_installed(tool) then
			missing[#missing + 1] = tool
		end
	end
	return missing
end

local function missing_treesitter_parsers(parsers)
	pcall(function()
		require("lazy").load({ plugins = { "nvim-treesitter" } })
	end)

	local ok, config = pcall(require, "nvim-treesitter.config")
	if not ok then
		return nil, "nvim-treesitter unavailable"
	end

	local installed = config.get_installed("parsers")
	local missing = {}
	for _, parser in ipairs(parsers) do
		if not vim.tbl_contains(installed, parser) then
			missing[#missing + 1] = parser
		end
	end
	return missing
end

local function undeclared_filetype_parsers(tools)
	local declared = {}
	local missing = {}
	local seen = {}

	for _, parser in ipairs(tools.treesitter_parsers) do
		declared[parser] = true
	end

	for _, by_filetype in ipairs({ tools.formatters_by_ft, tools.linters_by_ft }) do
		for filetype in pairs(by_filetype) do
			local parser = vim.treesitter.language.get_lang(filetype) or filetype
			if not declared[parser] and not seen[parser] then
				seen[parser] = true
				missing[#missing + 1] = string.format("%s (%s)", parser, filetype)
			end
		end
	end

	table.sort(missing)
	return missing
end

local function check_lsp_configs(results, tools)
	pcall(function()
		require("lazy").load({ plugins = { "nvim-lspconfig" } })
	end)

	for _, server in ipairs(tools.lsp_servers) do
		local config = vim.lsp.config[server]
		if not config then
			add(results, "ERR", "LSP " .. server, "missing config")
		elseif not config.root_markers and not config.root_dir then
			add(results, "WARN", "LSP " .. server, "no root markers/root_dir")
		else
			add(results, "OK", "LSP " .. server, "configured")
		end
	end
end

local function build_report(results)
	local lines = {
		"# Neovim Config Health",
		"",
		string.format("Generated: %s", os.date("%Y-%m-%d %H:%M:%S")),
		"",
	}

	local errors = 0
	local warnings = 0
	for _, result in ipairs(results) do
		if result.status == "ERR" then
			errors = errors + 1
		elseif result.status == "WARN" then
			warnings = warnings + 1
		end
		lines[#lines + 1] = string.format("- [%s] %s: %s", result.status, result.name, result.detail or "")
	end

	table.insert(lines, 4, string.format("Summary: %d error(s), %d warning(s)", errors, warnings))
	return lines, errors, warnings
end

local function show_report(lines, errors, warnings)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "markdown"
	vim.api.nvim_buf_set_name(buf, "ConfigHealth")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.cmd("botright split")
	vim.api.nvim_win_set_buf(0, buf)

	local level = errors > 0 and vim.log.levels.ERROR or (warnings > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
	vim.notify(string.format("ConfigHealth: %d error(s), %d warning(s)", errors, warnings), level, { title = "Nvim" })
end

local function health_start(name)
	if vim.health.start then
		vim.health.start(name)
	else
		vim.health.report_start(name)
	end
end

local function health_ok(message)
	if vim.health.ok then
		vim.health.ok(message)
	else
		vim.health.report_ok(message)
	end
end

local function health_warn(message)
	if vim.health.warn then
		vim.health.warn(message)
	else
		vim.health.report_warn(message)
	end
end

local function health_error(message)
	if vim.health.error then
		vim.health.error(message)
	else
		vim.health.report_error(message)
	end
end

function M.collect()
	local tools = require("config.tools")
	local results = {}

	check_tools_schema(results, tools)

	add(results, vim.o.cmdheight == 1 and "OK" or "ERR", "cmdheight", tostring(vim.o.cmdheight))
	add(
		results,
		require("lazy.core.config").plugins["noice.nvim"] == nil and "OK" or "ERR",
		"Noice",
		"not in Lazy spec"
	)

	local duplicates = duplicate_keymaps()
	add(
		results,
		#duplicates == 0 and "OK" or "ERR",
		"global keymap duplicates",
		#duplicates == 0 and "none" or table.concat(duplicates, ", ")
	)

	local core_maps = global_core_keymaps()
	add(
		results,
		#core_maps == 0 and "OK" or "ERR",
		"global cmdline/search keymaps",
		#core_maps == 0 and "none" or table.concat(core_maps, ", ")
	)

	for _, command in ipairs({ "DashboardAnimationToggle", "CodeCompanionCheck", "TSInstallConfigured" }) do
		add(
			results,
			command_exists(command) and "OK" or "ERR",
			":" .. command,
			command_exists(command) and "available" or "missing"
		)
	end

	local frame_count = dashboard_frame_count()
	add(
		results,
		frame_count > 0 and "OK" or "ERR",
		"dashboard animation assets",
		string.format("%d frame(s)", frame_count)
	)

	local missing_tools, mason_err = missing_mason_tools(tools.mason_tools)
	if mason_err then
		add(results, "WARN", "Mason tools", mason_err)
	else
		add(
			results,
			#missing_tools == 0 and "OK" or "ERR",
			"Mason tools",
			#missing_tools == 0 and "all installed" or table.concat(missing_tools, ", ")
		)
	end

	local missing_parsers, parser_err = missing_treesitter_parsers(tools.treesitter_parsers)
	if parser_err then
		add(results, "WARN", "Treesitter parsers", parser_err)
	else
		add(
			results,
			#missing_parsers == 0 and "OK" or "WARN",
			"Treesitter parsers",
			#missing_parsers == 0 and "all installed" or table.concat(missing_parsers, ", ")
		)
	end

	local undeclared_parsers = undeclared_filetype_parsers(tools)
	add(
		results,
		#undeclared_parsers == 0 and "OK" or "WARN",
		"Treesitter filetype coverage",
		#undeclared_parsers == 0 and "all configured filetypes have declared parsers"
			or table.concat(undeclared_parsers, ", ")
	)

	local missing_executables = {}
	for _, tool in ipairs(flatten_tools(tools.formatters_by_ft, tools.linters_by_ft, tools.linter_commands)) do
		if vim.fn.executable(tool) == 0 then
			missing_executables[#missing_executables + 1] = tool
		end
	end
	add(
		results,
		#missing_executables == 0 and "OK" or "ERR",
		"formatter/linter executables",
		#missing_executables == 0 and "all available" or table.concat(missing_executables, ", ")
	)

	local ai = require("config.ai")
	local missing_ai = ai.missing_credentials()
	add(results, missing_ai and "WARN" or "OK", "CodeCompanion adapter", missing_ai or ai.adapter)

	check_lsp_configs(results, tools)

	return results
end

function M.run()
	local lines, errors, warnings = build_report(M.collect())
	show_report(lines, errors, warnings)
end

function M.check()
	health_start("Neovim config")

	for _, result in ipairs(M.collect()) do
		local message = string.format("%s: %s", result.name, result.detail or "")
		if result.status == "OK" then
			health_ok(message)
		elseif result.status == "WARN" then
			health_warn(message)
		else
			health_error(message)
		end
	end
end

function M.sync_tools()
	pcall(function()
		require("lazy").load({ plugins = { "mason-tool-installer.nvim", "nvim-treesitter" } })
	end)
	pcall(vim.cmd, "MasonToolsInstall")
	pcall(vim.cmd, "TSInstallConfigured")
end

function M.setup()
	vim.api.nvim_create_user_command("ConfigHealth", function()
		M.run()
	end, { desc = "Check this Neovim configuration" })

	vim.api.nvim_create_user_command("ConfigSyncTools", function()
		M.sync_tools()
	end, { desc = "Install configured Mason tools and Treesitter parsers" })
end

return M
