-- ================================================================================================
-- TITLE : yamlls (YAML Language Server) LSP Setup
-- LINKS :
--   > github: https://github.com/redhat-developer/yaml-language-server
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	vim.lsp.config("yamlls", {
		capabilities = capabilities,
		root_markers = {
			".yamllint",
			".yamllint.yaml",
			".yamllint.yml",
			"docker-compose.yml",
			"docker-compose.yaml",
			"compose.yml",
			"compose.yaml",
			".github",
		},
		settings = {
			yaml = {
				schemas = {
					["https://json.schemastore.org/docker-compose.json"] = {
						"docker-compose*.yml",
						"docker-compose*.yaml",
						"compose.yml",
						"compose.yaml",
					},
				},
				validate = true,
				format = {
					enable = true,
				},
			},
		},
		filetypes = { "yaml" },
	})
end
