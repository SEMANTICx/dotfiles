-- ================================================================================================
-- TITLE : jsonls (JSON Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/microsoft/vscode-json-languageservice
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	vim.lsp.config("jsonls", {
		capabilities = capabilities,
		filetypes = { "json", "jsonc" },
		root_markers = {
			"package.json",
			"tsconfig.json",
			"jsconfig.json",
			"biome.json",
			"deno.json",
			"deno.jsonc",
		},
	})
end
