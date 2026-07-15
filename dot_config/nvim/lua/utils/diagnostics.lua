local M = {}

local diagnostic_signs = {
	Error = "󰅙",
	Warn = "",
	Hint = "󰌵",
	Info = "󰋼",
}

M.setup = function()
	vim.diagnostic.config({
		severity_sort = true,
		underline = true,
		virtual_text = false,
		virtual_lines = false,
		float = {
			border = "rounded",
			source = "if_many",
			header = "",
			prefix = "",
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
				[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
				[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
				[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
			},
		},
	})
end

return M
