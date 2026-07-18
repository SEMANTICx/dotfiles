local M = {}

local function prettier()
	return { "prettierd", "prettier", stop_after_first = true }
end

M.language_order = {
	"lua",
	"python",
	"go",
	"json",
	"typescript",
	"bash",
	"c_cpp",
	"docker",
	"emmet",
	"yaml",
	"tailwind",
	"markdown",
	"svelte_vue",
	"rust",
	"zig",
	"solidity",
	"latex",
	"typst",
	"lean",
	"codeql",
}

M.languages = {
	lua = {
		lsp = "lua_ls",
		mason = { "lua-language-server", "stylua" },
		treesitter = { "lua" },
		formatters = { lua = { "stylua" } },
	},
	python = {
		lsp = "pyright",
		mason = { "pyright", "ruff" },
		treesitter = { "python" },
		formatters = { python = { "ruff_format" } },
		linters = { python = { "ruff" } },
	},
	go = {
		lsp = "gopls",
		mason = { "gopls", "revive", "gofumpt" },
		treesitter = { "go" },
		formatters = { go = { "gofumpt" } },
		linters = { go = { "revive" } },
	},
	json = {
		lsp = "jsonls",
		mason = { "json-lsp", "fixjson" },
		treesitter = { "json" },
		formatters = {
			json = { "fixjson" },
			jsonc = { "fixjson" },
		},
	},
	typescript = {
		lsp = "ts_ls",
		mason = { "typescript-language-server", "prettier", "prettierd", "eslint_d" },
		treesitter = { "javascript", "typescript", "tsx" },
		formatters = {
			javascript = prettier(),
			javascriptreact = prettier(),
			typescript = prettier(),
			typescriptreact = prettier(),
		},
		linters = {
			javascript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescript = { "eslint_d" },
			typescriptreact = { "eslint_d" },
		},
	},
	bash = {
		lsp = "bashls",
		mason = { "bash-language-server", "shellcheck", "shfmt" },
		treesitter = { "bash" },
		formatters = { sh = { "shfmt" } },
		linters = { sh = { "shellcheck" } },
	},
	c_cpp = {
		lsp = "clangd",
		mason = { "clangd", "clang-format", "cpplint" },
		treesitter = { "c", "cpp" },
		formatters = {
			c = { "clang_format" },
			cpp = { "clang_format" },
		},
		linters = {
			c = { "cpplint" },
			cpp = { "cpplint" },
		},
	},
	docker = {
		lsp = "dockerls",
		mason = { "dockerfile-language-server", "hadolint" },
		treesitter = { "dockerfile" },
		linters = { dockerfile = { "hadolint" } },
	},
	emmet = {
		lsp = "emmet_ls",
		mason = { "emmet-ls" },
		treesitter = { "css", "html" },
		formatters = {
			css = prettier(),
			html = prettier(),
		},
	},
	yaml = {
		lsp = "yamlls",
		mason = { "yaml-language-server", "prettier", "prettierd" },
		treesitter = { "yaml" },
		formatters = { yaml = prettier() },
	},
	tailwind = {
		lsp = "tailwindcss",
		mason = { "tailwindcss-language-server" },
	},
	markdown = {
		treesitter = { "markdown", "markdown_inline" },
	},
	svelte_vue = {
		mason = { "prettier", "prettierd", "eslint_d" },
		treesitter = { "svelte", "vue" },
		formatters = {
			svelte = prettier(),
			vue = prettier(),
		},
		linters = {
			svelte = { "eslint_d" },
			vue = { "eslint_d" },
		},
	},
	rust = {
		mason = { "codelldb" },
		treesitter = { "rust" },
	},
	zig = {
		lsp = "zls",
		mason = { "zls" },
		treesitter = { "zig" },
	},
	solidity = {
		treesitter = { "solidity" },
	},
	latex = {
		lsp = "texlab",
		mason = { "texlab", "latexindent" },
		treesitter = { "latex" },
		formatters = { tex = { "latexindent" } },
	},
	typst = {
		lsp = "tinymist",
		mason = { "tinymist" },
		treesitter = { "typst" },
	},
	lean = {
		-- Keep optional language support dormant until its external toolchain is
		-- present; once installed, :TSInstallConfigured picks up the parser.
		treesitter = (vim.fn.executable("lean") == 1 or vim.fn.executable("lake") == 1) and { "lean" } or {},
	},
	codeql = {
		-- The language server is enabled only after the external CodeQL CLI is
		-- installed; opening .ql files before that remains error-free.
		lsp = vim.fn.executable("codeql") == 1 and "codeqlls" or nil,
		treesitter = vim.fn.executable("codeql") == 1 and { "ql" } or {},
	},
}

M.linter_commands = {
	cpplint = "cpplint",
	eslint_d = "eslint_d",
	hadolint = "hadolint",
	revive = "revive",
	ruff = "ruff",
	ruff_format = "ruff",
	shellcheck = "shellcheck",
}

local function add_unique(list, seen, value)
	if not value or seen[value] then
		return
	end
	seen[value] = true
	list[#list + 1] = value
end

local function add_values(list, seen, values)
	for _, value in ipairs(values or {}) do
		add_unique(list, seen, value)
	end
end

local function build_list(field)
	local list = {}
	local seen = {}

	for _, name in ipairs(M.language_order) do
		local language = M.languages[name]
		local value = language and language[field]
		if type(value) == "string" then
			add_unique(list, seen, value)
		elseif type(value) == "table" then
			add_values(list, seen, value)
		end
	end

	return list
end

local function build_by_filetype(field)
	local by_filetype = {}

	for _, name in ipairs(M.language_order) do
		local language = M.languages[name]
		for filetype, config in pairs((language and language[field]) or {}) do
			by_filetype[filetype] = config
		end
	end

	return by_filetype
end

M.lsp_servers = build_list("lsp")
M.mason_tools = build_list("mason")
M.treesitter_parsers = build_list("treesitter")
M.formatters_by_ft = build_by_filetype("formatters")
M.linters_by_ft = build_by_filetype("linters")

return M
