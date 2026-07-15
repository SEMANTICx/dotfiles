local function on_attach(client, bufnr)
	local function execute(command, arguments)
		client:request("workspace/executeCommand", {
			command = command,
			arguments = arguments,
		}, nil, bufnr)
	end

	vim.keymap.set("n", "<leader>wm", function()
		execute("tinymist.pinMain", { vim.api.nvim_buf_get_name(bufnr) })
	end, { buffer = bufnr, desc = "Writing: Typst pin main" })

	vim.keymap.set("n", "<leader>wu", function()
		execute("tinymist.pinMain", { vim.NIL })
	end, { buffer = bufnr, desc = "Writing: Typst unpin main" })

	local export_formats = {
		{ label = "PDF", command = "tinymist.exportPdf" },
		{ label = "SVG", command = "tinymist.exportSvg" },
		{ label = "PNG", command = "tinymist.exportPng" },
		{ label = "HTML", command = "tinymist.exportHtml" },
		{ label = "Markdown", command = "tinymist.exportMarkdown" },
	}

	local function export(format, handler)
		local path = vim.api.nvim_buf_get_name(bufnr)
		if path == "" then
			vim.notify("Typst export requires a saved file", vim.log.levels.ERROR)
			return
		end

		client:exec_cmd({
			title = "Export Typst to " .. format.label,
			command = format.command,
			arguments = { path },
		}, { bufnr = bufnr }, handler)
	end

	for _, format in ipairs(export_formats) do
		vim.api.nvim_buf_create_user_command(bufnr, "TypstExport" .. format.label, function()
			export(format)
		end, { desc = "Export this Typst document to " .. format.label })
	end

	vim.api.nvim_buf_create_user_command(bufnr, "TypstOpenPDF", function()
		if vim.fn.executable("sioyek") ~= 1 then
			vim.notify("Sioyek is not installed or not on PATH", vim.log.levels.ERROR)
			return
		end

		export(export_formats[1], function(err, result)
			if err then
				vim.notify("Typst PDF export failed: " .. (err.message or vim.inspect(err)), vim.log.levels.ERROR)
				return
			end

			local pdf_path = result and result.path
			if not pdf_path and result and result.items and result.items[1] then
				pdf_path = result.items[1].path
			end
			if not pdf_path then
				vim.notify("Tinymist did not return an exported PDF path", vim.log.levels.ERROR)
				return
			end

			vim.fn.jobstart({ "sioyek", "--reuse-window", pdf_path }, { detach = true })
		end)
	end, { desc = "Export this Typst document to PDF and open it in Sioyek" })

	vim.keymap.set("n", "<leader>wo", "<cmd>TypstOpenPDF<cr>", {
		buffer = bufnr,
		desc = "Writing: export Typst PDF and open in Sioyek",
	})

	vim.keymap.set("n", "<leader>we", function()
		vim.ui.select(export_formats, {
			prompt = "Export Typst as",
			format_item = function(format)
				return format.label
			end,
		}, function(format)
			if format then
				export(format)
			end
		end)
	end, { buffer = bufnr, desc = "Writing: export Typst document" })
end

return function(capabilities)
	vim.lsp.config("tinymist", {
		capabilities = capabilities,
		filetypes = { "typst" },
		root_markers = { "typst.toml", ".git" },
		on_attach = on_attach,
		settings = {
			formatterMode = "typstyle",
			exportPdf = "onType",
			semanticTokens = "disable",
		},
	})
end
