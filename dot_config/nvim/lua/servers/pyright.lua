-- ================================================================================================
-- TITLE : pyright (Python Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/microsoft/pyright
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil This function doesn't return a value, it configures the LSP server
return function(capabilities)
	vim.lsp.config("pyright", {
		capabilities = capabilities,
		root_markers = {
			"pyrightconfig.json",
			"pyproject.toml",
			"setup.py",
			"setup.cfg",
			"requirements.txt",
			"Pipfile",
			"poetry.lock",
			"uv.lock",
			"tox.ini",
		},
		settings = {
			pyright = {
				disableOrganizeImports = false,
				analysis = {
					useLibraryCodeForTypes = true,
					autoSearchPaths = true,
					diagnosticMode = "openFilesOnly",
					autoImportCompletions = true,
				},
			},
		},
	})
end
