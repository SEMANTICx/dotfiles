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

	-- native neovim keymaps
	keymap("n", "<leader>gd", vim.lsp.buf.definition, opts) -- goto definition
	keymap("n", "<leader>gD", vim.lsp.buf.declaration, opts) -- goto declaration
	keymap("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts) -- goto definition in split
	keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Code actions
	keymap("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Rename symbol
	keymap("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts) -- Line diagnostics (float)
	keymap("n", "<leader>dd", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, vim.tbl_extend("force", opts, { desc = "Cursor diagnostics" }))
	keymap("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts) -- previous diagnostic
	keymap("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts) -- next diagnostic
	keymap("n", "K", vim.lsp.buf.hover, opts) -- hover documentation

	-- fzf-lua keymaps
	keymap("n", "<leader>fd", "<cmd>FzfLua lsp_finder<CR>", opts) -- LSP Finder (definition + references)
	keymap("n", "<leader>fr", "<cmd>FzfLua lsp_references<CR>", opts) -- Show all references to the symbol under the cursor
	keymap("n", "<leader>ft", "<cmd>FzfLua lsp_typedefs<CR>", opts) -- Jump to the type definition of the symbol under the cursor
	keymap("n", "<leader>fw", "<cmd>FzfLua lsp_workspace_symbols<CR>", opts) -- Search for any symbol across the entire project/workspace
	keymap("n", "<leader>fi", "<cmd>FzfLua lsp_implementations<CR>", opts) -- Go to implementation

	-- Order Imports (if supported by the client LSP)
	if client:supports_method("textDocument/codeAction", bufnr) then
		keymap("n", "<leader>oi", function()
			require("utils.organize_imports").run(bufnr)
		end, opts)
	end

	-- === DAP keymaps ===
	if client.name == "rust-analyzer" then -- debugging only configured for Rust
		local dap = require("dap")
		local function with_dapui(callback)
			pcall(require, "dapui")
			callback()
		end

		keymap("n", "<leader>dc", function()
			with_dapui(dap.continue)
		end, opts) -- Continue / Start
		keymap("n", "<leader>do", dap.step_over, opts) -- Step over
		keymap("n", "<leader>di", dap.step_into, opts) -- Step into
		keymap("n", "<leader>du", dap.step_out, opts) -- Step out
		keymap("n", "<leader>db", dap.toggle_breakpoint, opts) -- Toggle breakpoint
		keymap("n", "<leader>dr", dap.repl.open, opts) -- Open DAP REPL
	end
end

return M
