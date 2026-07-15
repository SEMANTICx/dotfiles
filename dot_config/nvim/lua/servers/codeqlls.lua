return function(capabilities)
	local additional_packs = {}
	for _, path in ipairs({ "/opt/codeql", vim.fn.expand("~/.codeql/packages") }) do
		if vim.uv.fs_stat(path) then
			table.insert(additional_packs, path)
		end
	end

	vim.lsp.config("codeqlls", {
		capabilities = capabilities,
		cmd = { "codeql", "execute", "language-server", "--check-errors", "ON_CHANGE", "-q" },
		filetypes = { "ql", "qll" },
		root_markers = { "qlpack.yml", ".git" },
		settings = { additional_packs = additional_packs },
	})
end
