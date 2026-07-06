-- ================================================================================================
-- TITLE : compatibility shims
-- ABOUT : small compatibility layer for plugins that lag behind Neovim nightly API changes.
-- ================================================================================================

-- Some plugins still reference APIs that moved or disappeared on Neovim nightly.
-- Revisit after plugin updates; this file should shrink rather than become permanent config.

vim.F = vim.F or {}
-- Used by plugins that still call deprecated vim.F.npcall on newer Neovim builds.
if vim.npcall then
	vim.F.npcall = vim.npcall
else
	vim.F.npcall = function(fn, ...)
		local ok, result = pcall(fn, ...)
		if ok then
			return result
		end
	end
end

if vim.lsp then
	-- Used by older LSP-adjacent plugins that have not moved to client.attached_buffers.
	vim.lsp.get_buffers_by_client_id = function(client_id)
		local client = vim.lsp.get_client_by_id(client_id)
		if not client or not client.attached_buffers then
			return {}
		end

		return vim.tbl_keys(client.attached_buffers)
	end
end
