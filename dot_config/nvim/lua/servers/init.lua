local capabilities = require("blink.cmp").get_lsp_capabilities()
local tools = require("config.tools")

-- Language Server Protocol (LSP)
for _, server in ipairs(tools.lsp_servers) do
	require("servers." .. server)(capabilities)
end

vim.lsp.enable(tools.lsp_servers)
