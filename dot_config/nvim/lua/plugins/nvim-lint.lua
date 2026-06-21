-- ================================================================================================
-- TITLE : nvim-lint
-- ABOUT : Asynchronous linting through external command-line tools.
-- LINKS :
--   > github : https://github.com/mfussenegger/nvim-lint
-- ================================================================================================

return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local tools = require("config.tools")

		lint.linters_by_ft = tools.linters_by_ft

		local function available_linters(bufnr)
			local ft = vim.bo[bufnr].filetype
			local configured = lint.linters_by_ft[ft] or {}
			local available = {}

			for _, name in ipairs(configured) do
				local command = tools.linter_commands[name] or name
				if vim.fn.executable(command) == 1 then
					table.insert(available, name)
				end
			end

			return available
		end

		local group = vim.api.nvim_create_augroup("LintConfig", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = group,
			callback = function(args)
				local names = available_linters(args.buf)
				if #names > 0 then
					lint.try_lint(names)
				end
			end,
		})
	end,
}
