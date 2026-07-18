local M = {}

M.on_attach = function(event)
	if not event.data then
		return
	end

	local ok, client = pcall(vim.lsp.get_client_by_id, event.data.client_id)

	if not ok or not client then
		return
	end
	local bufnr = event.buf
	local keymap = vim.keymap.set

	local opts = {
		noremap = true, -- prevent recursive mapping
		silent = true, -- don't print the command to the cli
		buffer = bufnr, -- restrict the keymap to the local buffer number
	}
	local function map(mode, lhs, rhs, desc)
		keymap(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
	end

	-- native neovim keymaps
	map("n", "<leader>gd", vim.lsp.buf.definition, "LSP: go to definition")
	map("n", "<leader>gD", vim.lsp.buf.declaration, "LSP: go to declaration")
	map("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, "LSP: definition in split")
	map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
	map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename symbol")
	map("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, "Diagnostics: current line")
	map("n", "<leader>dd", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, "Diagnostics: cursor")
	map("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, "Diagnostics: previous")
	map("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, "Diagnostics: next")
	map("n", "K", vim.lsp.buf.hover, "LSP: hover documentation")

	-- fzf-lua keymaps
	map("n", "<leader>fd", "<cmd>FzfLua lsp_finder<CR>", "LSP: finder")
	map("n", "<leader>fr", "<cmd>FzfLua lsp_references<CR>", "LSP: references")
	map("n", "<leader>ft", "<cmd>FzfLua lsp_typedefs<CR>", "LSP: type definitions")
	map("n", "<leader>fw", "<cmd>FzfLua lsp_workspace_symbols<CR>", "LSP: workspace symbols")
	map("n", "<leader>fi", "<cmd>FzfLua lsp_implementations<CR>", "LSP: implementations")

	-- Order Imports (if supported by the client LSP)
	if client:supports_method("textDocument/codeAction", bufnr) then
		map("n", "<leader>oi", function()
			require("utils.organize_imports").run(bufnr)
		end, "LSP: organize imports")
	end

	-- === DAP keymaps ===
	if client.name == "rust-analyzer" then -- debugging only configured for Rust
		local dap = require("dap")
		local function with_dapui(callback)
			pcall(require, "dapui")
			callback()
		end

		map("n", "<leader>dc", function()
			with_dapui(dap.continue)
		end, "DAP: continue or start")
		map("n", "<leader>do", dap.step_over, "DAP: step over")
		map("n", "<leader>di", dap.step_into, "DAP: step into")
		map("n", "<leader>du", dap.step_out, "DAP: step out")
		map("n", "<leader>db", dap.toggle_breakpoint, "DAP: toggle breakpoint")
		map("n", "<leader>dr", dap.repl.open, "DAP: open REPL")
	end
end

return M
