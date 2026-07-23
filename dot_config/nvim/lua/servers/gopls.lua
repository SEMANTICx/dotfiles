-- ================================================================================================
-- TITLE : gopls (Golang Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/golang/tools/tree/master/gopls
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	vim.lsp.config("gopls", {
		capabilities = capabilities,
		root_markers = {
			"go.work",
			"go.mod",
		},
		settings = {
			gopls = {
				gofumpt = true,
				staticcheck = false,
				analyses = {
					fieldalignment = false,
					nilness = true,
					shadow = false,
					unusedparams = true,
					unusedwrite = true,
					useany = true,
				},
				semanticTokens = true,
			},
		},
	})
end
