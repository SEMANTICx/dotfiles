-- ================================================================================================
-- TITLE : zls (Zig Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/zigtools/zls
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	vim.lsp.config("zls", {
		capabilities = capabilities,
		filetypes = { "zig", "zir" },
		root_markers = {
			"build.zig",
			"build.zig.zon",
			"zls.json",
		},
		settings = {
			zls = {
				completion_label_details = true,
				enable_argument_placeholders = true,
				enable_build_on_save = false,
				enable_snippets = true,
				inlay_hints_hide_redundant_param_names = true,
				inlay_hints_hide_redundant_param_names_last_token = true,
				inlay_hints_show_builtin = true,
				inlay_hints_show_parameter_name = true,
				inlay_hints_show_struct_literal_field_type = true,
				inlay_hints_show_variable_type_hints = true,
				semantic_tokens = "full",
				warn_style = false,
			},
		},
	})
end
