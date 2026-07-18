-- ================================================================================================
-- TITLE : tailwindcss LSP Setup
-- LINKS :
--   > github: https://github.com/tailwindlabs/tailwindcss-intellisense
-- ================================================================================================

--- @param capabilities table LSP client capabilities from the completion engine
--- @return nil
return function(capabilities)
	local config_markers = {
		"tailwind.config.js",
		"tailwind.config.cjs",
		"tailwind.config.mjs",
		"tailwind.config.ts",
	}
	local postcss_markers = {
		"postcss.config.js",
		"postcss.config.cjs",
		"postcss.config.mjs",
		"postcss.config.ts",
	}

	local function package_uses_tailwind(path)
		local ok, lines = pcall(vim.fn.readfile, path)
		local decoded_ok, package = pcall(vim.json.decode, ok and table.concat(lines, "\n") or "")
		if not decoded_ok or type(package) ~= "table" then
			return false
		end

		for _, field in ipairs({ "dependencies", "devDependencies", "peerDependencies", "optionalDependencies" }) do
			if type(package[field]) == "table" and package[field].tailwindcss ~= nil then
				return true
			end
		end

		return false
	end

	local function lockfile_uses_tailwind(path)
		local ok, lines = pcall(vim.fn.readfile, path)
		return ok and table.concat(lines, "\n"):find("tailwind", 1, true) ~= nil
	end

	local function css_buffer_uses_tailwind(bufnr)
		local filetype = vim.bo[bufnr].filetype
		if not vim.tbl_contains({ "css", "less", "postcss", "sass", "scss", "stylus", "sugarss" }, filetype) then
			return false
		end

		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		return table.concat(lines, "\n"):find("tailwindcss", 1, true) ~= nil
	end

	vim.lsp.config("tailwindcss", {
		capabilities = capabilities,
		workspace_required = true,
		root_dir = function(bufnr, on_dir)
			local filename = vim.api.nvim_buf_get_name(bufnr)
			if filename == "" then
				return
			end

			local start = vim.fs.dirname(filename)
			local marker = vim.fs.find(config_markers, { path = start, upward = true })[1]
			if marker then
				on_dir(vim.fs.dirname(marker))
				return
			end

			for _, postcss_path in ipairs(vim.fs.find(postcss_markers, { path = start, upward = true })) do
				if lockfile_uses_tailwind(postcss_path) then
					on_dir(vim.fs.dirname(postcss_path))
					return
				end
			end

			for _, package_path in
				ipairs(vim.fs.find("package.json", { path = start, upward = true, limit = math.huge }))
			do
				if package_uses_tailwind(package_path) then
					on_dir(vim.fs.dirname(package_path))
					return
				end
			end

			for _, lockfile in ipairs(vim.fs.find({ "mix.lock", "Gemfile.lock" }, { path = start, upward = true })) do
				if lockfile_uses_tailwind(lockfile) then
					on_dir(vim.fs.dirname(lockfile))
					return
				end
			end

			if css_buffer_uses_tailwind(bufnr) then
				on_dir(vim.fs.root(filename, { ".git" }) or start)
			end
		end,
	})
end
