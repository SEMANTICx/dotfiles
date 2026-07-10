local failures = {}
local checks = 0

local function fail(name, detail)
	failures[#failures + 1] = string.format("%s: %s", name, detail)
	vim.api.nvim_err_writeln(string.format("[FAIL] %s: %s", name, detail))
end

local function report_github_error(messages)
	if vim.env.GITHUB_ACTIONS ~= "true" then
		return
	end

	local detail = table.concat(messages, "\n"):gsub("%%", "%%25"):gsub("\r", "%%0D"):gsub("\n", "%%0A")
	vim.api.nvim_out_write("::error title=Neovim LSP attachment::" .. detail .. "\n")
end

local cases = {
	{
		name = "lua_ls",
		executable = "lua-language-server",
		file = "main.lua",
		filetype = "lua",
		files = {
			[".luarc.json"] = { "{}" },
			["main.lua"] = { "local answer = 42", "return answer" },
		},
	},
	{
		name = "pyright",
		executable = "pyright-langserver",
		file = "main.py",
		filetype = "python",
		files = {
			["pyproject.toml"] = { "[project]", 'name = "nvim-lsp-smoke"', 'version = "0.1.0"' },
			["main.py"] = { "answer: int = 42", "print(answer)" },
		},
	},
	{
		name = "ts_ls",
		executable = "typescript-language-server",
		file = "main.ts",
		filetype = "typescript",
		files = {
			["package.json"] = { '{"private":true}' },
			["package-lock.json"] = { '{"lockfileVersion":3}' },
			["tsconfig.json"] = { '{"compilerOptions":{"strict":true}}' },
			["main.ts"] = { "const answer: number = 42", "console.log(answer)" },
		},
	},
}

if vim.env.NVIM_LSP_CASE and vim.env.NVIM_LSP_CASE ~= "" then
	cases = vim.tbl_filter(function(case)
		return case.name == vim.env.NVIM_LSP_CASE
	end, cases)
	assert(#cases == 1, "unknown NVIM_LSP_CASE: " .. vim.env.NVIM_LSP_CASE)
end

require("lazy").load({ plugins = { "nvim-lspconfig" } })

local temp = vim.fn.tempname()
vim.fn.mkdir(temp, "p")

local function stop_clients(bufnr)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		client:stop(true)
	end
	vim.wait(2000, function()
		return #vim.lsp.get_clients({ bufnr = bufnr }) == 0
	end, 50)
end

local function lsp_log_tail()
	local path = vim.lsp.log.get_filename()
	if vim.fn.filereadable(path) == 0 then
		return "LSP log is unavailable: " .. path
	end

	local lines = vim.fn.readfile(path)
	local first = math.max(1, #lines - 19)
	return table.concat(vim.list_slice(lines, first), "\n")
end

for _, case in ipairs(cases) do
	checks = checks + 1
	local bufnr
	local ok, err = pcall(function()
		assert(vim.fn.executable(case.executable) == 1, "missing executable: " .. case.executable)

		local root = vim.fs.joinpath(temp, case.name)
		vim.fn.mkdir(root, "p")
		for path, lines in pairs(case.files) do
			vim.fn.writefile(lines, vim.fs.joinpath(root, path))
		end

		vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(root, case.file)))
		bufnr = vim.api.nvim_get_current_buf()
		vim.bo[bufnr].filetype = case.filetype
		vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr, modeline = false })
		vim.lsp.enable(case.name, false)
		vim.lsp.enable(case.name)
		local attached = vim.wait(20000, function()
			return #vim.lsp.get_clients({ bufnr = bufnr, name = case.name }) > 0
		end, 100)
		assert(
			attached,
			string.format(
				"client did not attach within 20 seconds; active clients: %s; log tail:\n%s",
				vim.inspect(vim.tbl_map(function(client)
					return client.name
				end, vim.lsp.get_clients())),
				lsp_log_tail()
			)
		)

		local client = assert(vim.lsp.get_clients({ bufnr = bufnr, name = case.name })[1])
		assert(
			vim.fs.normalize(client.config.root_dir) == vim.fs.normalize(root),
			string.format("unexpected root: %s", client.config.root_dir or "nil")
		)

		local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
		local responses, request_err = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, 10000)
		assert(responses, request_err or "documentSymbol request timed out")
		local response = responses[client.id]
		assert(response, "server returned no documentSymbol response")
		assert(not response.err, vim.inspect(response.err))
	end)

	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		stop_clients(bufnr)
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end

	if ok then
		vim.api.nvim_out_write(string.format("[OK] %s attached and answered documentSymbol\n", case.name))
	else
		fail(case.name, err)
	end
end

vim.fn.delete(temp, "rf")

if #failures > 0 then
	report_github_error(failures)
	vim.api.nvim_err_writeln(string.format("\n%d/%d LSP attachment checks failed:", #failures, checks))
	for _, failure in ipairs(failures) do
		vim.api.nvim_err_writeln("- " .. failure)
	end
	vim.api.nvim_err_writeln("LSP log: " .. vim.lsp.log.get_filename())
	vim.cmd("cquit 1")
else
	vim.api.nvim_out_write(string.format("\nAll %d LSP attachment checks passed.\n", checks))
	vim.cmd("qa!")
end
