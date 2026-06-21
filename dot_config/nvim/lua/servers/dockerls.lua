-- ================================================================================================
-- TITLE : dockerls (Docker Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/rcjsuen/dockerfile-language-server-nodejs
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	vim.lsp.config('dockerls',{
		capabilities = capabilities,
		filetypes = { "dockerfile" },
	})
end
