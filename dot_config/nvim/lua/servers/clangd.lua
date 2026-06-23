-- ================================================================================================
-- TITLE : clangd (C/C++ Language Server) LSP Setup
-- LINKS :
--   > website: https://clangd.llvm.org/
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	vim.lsp.config("clangd", {
		capabilities = capabilities,
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy=false",
			"--completion-style=detailed",
			"--fallback-style=llvm",
			"--function-arg-placeholders",
			"--header-insertion=iwyu",
			"--offset-encoding=utf-16",
		},
		filetypes = { "c", "cpp" },
		root_markers = {
			".clangd",
			"compile_commands.json",
			"compile_flags.txt",
			"CMakeLists.txt",
			"meson.build",
			"Makefile",
		},
	})
end
