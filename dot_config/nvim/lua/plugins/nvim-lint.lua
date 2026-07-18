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
		local timers = {}

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

		local function close_timer(bufnr)
			local timer = timers[bufnr]
			if not timer then
				return
			end

			timers[bufnr] = nil
			timer:stop()
			if not timer:is_closing() then
				timer:close()
			end
		end

		local function lint_buffer(bufnr)
			if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
				return
			end

			local names = available_linters(bufnr)
			if #names > 0 then
				vim.api.nvim_buf_call(bufnr, function()
					lint.try_lint(names)
				end)
			end
		end

		local function debounce_lint(bufnr)
			close_timer(bufnr)
			if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
				return
			end
			if #(lint.linters_by_ft[vim.bo[bufnr].filetype] or {}) == 0 then
				return
			end

			local timer = assert(vim.uv.new_timer())
			timers[bufnr] = timer
			local delay = tonumber(vim.g.lint_debounce_ms) or 300
			timer:start(
				delay,
				0,
				vim.schedule_wrap(function()
					if timers[bufnr] ~= timer then
						return
					end
					close_timer(bufnr)
					lint_buffer(bufnr)
				end)
			)
		end

		local group = vim.api.nvim_create_augroup("LintConfig", { clear = true })
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = group,
			callback = function(args)
				close_timer(args.buf)
				lint_buffer(args.buf)
			end,
		})
		vim.api.nvim_create_autocmd("InsertLeave", {
			group = group,
			callback = function(args)
				debounce_lint(args.buf)
			end,
		})
		vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
			group = group,
			callback = function(args)
				close_timer(args.buf)
			end,
		})

		local initial_bufnr = vim.api.nvim_get_current_buf()
		vim.schedule(function()
			debounce_lint(initial_bufnr)
		end)
	end,
}
