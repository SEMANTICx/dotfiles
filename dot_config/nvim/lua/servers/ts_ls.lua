-- ================================================================================================
-- TITLE : ts_ls (TypeScript Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/typescript-language-server/typescript-language-server
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	local project_markers = {
		"package-lock.json",
		"yarn.lock",
		"pnpm-lock.yaml",
		"bun.lockb",
		"bun.lock",
		"package.json",
		"tsconfig.json",
		"jsconfig.json",
		".git",
	}
	local format = {
		enable = false,
	}
	local inlay_hints = {
		enumMemberValues = { enabled = true },
		functionLikeReturnTypes = { enabled = true },
		parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = true },
		parameterTypes = { enabled = false },
		propertyDeclarationTypes = { enabled = true },
		variableTypes = { enabled = false, suppressWhenTypeMatchesName = true },
	}
	local preferences = {
		importModuleSpecifier = "shortest",
		importModuleSpecifierEnding = "minimal",
		includePackageJsonAutoImports = "auto",
		preferTypeOnlyAutoImports = true,
		quoteStyle = "auto",
		renameMatchingJsxTags = true,
		useAliasesForRenames = true,
	}

	vim.lsp.config("ts_ls", {
		capabilities = capabilities,
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = {
			"typescript",
			"javascript",
			"typescriptreact",
			"javascriptreact",
		},
		workspace_required = true,
		root_dir = function(bufnr, on_dir)
			local filename = vim.api.nvim_buf_get_name(bufnr)
			if filename == "" then
				return
			end

			local project_root = vim.fs.root(filename, project_markers)
			local deno_root = vim.fs.root(filename, { "deno.json", "deno.jsonc", "deno.lock" })
			if deno_root and (not project_root or #deno_root >= #project_root) then
				return
			end
			if project_root then
				on_dir(project_root)
			end
		end,
		settings = {
			javascript = {
				format = format,
				inlayHints = inlay_hints,
				preferences = preferences,
				updateImportsOnFileMove = {
					enabled = "always",
				},
			},
			typescript = {
				format = format,
				inlayHints = inlay_hints,
				preferences = preferences,
				updateImportsOnFileMove = {
					enabled = "always",
				},
			},
		},
	})
end
