-- ================================================================================================
-- TITLE : emmet_ls (Emmet Language Server) LSP Setup
-- ABOUT : Configures Emmet Language Server for web-related (e.g. TS/JS, CSS, Sass, Svelte, Vue)
-- LINKS :
--   > github: https://github.com/aca/emmet-ls
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	vim.lsp.config("emmet_ls", {
		capabilities = capabilities,
		filetypes = {
			"css",
			"html",
			"javascriptreact",
			"sass",
			"scss",
			"svelte",
			"typescriptreact",
			"vue",
		},
		root_markers = {
			"package.json",
			".git",
		},
	})
end
