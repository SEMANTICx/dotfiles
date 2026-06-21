-- ================================================================================================
-- TITLE : bashls (Bash Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/bash-lsp/bash-language-server
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	vim.lsp.config('bashls',{
		capabilities = capabilities,
		filetypes = { "sh", "bash", "zsh" },
	})
end
