local function build_settings()
	if vim.fn.executable("latexmk") == 1 then
		return {
			executable = "latexmk",
			args = { "-synctex=1", "-interaction=nonstopmode", "-file-line-error", "%f" },
			onSave = true,
		}
	end

	-- Tectonic is already part of this machine's toolchain and is a reliable
	-- fallback when latexmk is not installed.
	return {
		executable = "tectonic",
		args = { "-X", "compile", "%f", "--synctex", "--keep-logs" },
		onSave = true,
	}
end

local function on_attach(client, bufnr)
	vim.keymap.set("n", "<leader>wb", function()
		local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
		client:request("textDocument/build", params, function(err, result)
			if err then
				vim.notify("LaTeX build error: " .. vim.inspect(err), vim.log.levels.ERROR)
			elseif result and result.status == 0 then
				vim.notify("LaTeX build successful", vim.log.levels.INFO)
			else
				vim.notify("LaTeX build failed", vim.log.levels.WARN)
			end
		end, bufnr)
	end, { buffer = bufnr, desc = "Writing: LaTeX build" })

	vim.keymap.set("n", "<leader>wv", function()
		local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
		client:request("textDocument/forwardSearch", params, function(err)
			if err then
				vim.notify("LaTeX forward-search error: " .. vim.inspect(err), vim.log.levels.ERROR)
			end
		end, bufnr)
	end, { buffer = bufnr, desc = "Writing: LaTeX forward search" })
end

return function(capabilities)
	vim.lsp.config("texlab", {
		capabilities = capabilities,
		filetypes = { "tex", "bib", "plaintex" },
		root_markers = { ".latexmkrc", "Tectonic.toml", ".git" },
		on_attach = on_attach,
		settings = {
			texlab = {
				build = build_settings(),
				forwardSearch = {
					executable = "okular",
					args = { "--unique", "file:%p#src:%l%f" },
				},
			},
		},
	})
end
