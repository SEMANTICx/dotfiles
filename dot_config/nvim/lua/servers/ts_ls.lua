-- ================================================================================================
-- TITLE : ts_ls (TypeScript Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/typescript-language-server/typescript-language-server
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
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
		filetypes = {
			"typescript",
			"javascript",
			"typescriptreact",
			"javascriptreact",
		},
		root_markers = {
			"package.json",
			"tsconfig.json",
			"jsconfig.json",
			"deno.json",
			"deno.jsonc",
		},
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
