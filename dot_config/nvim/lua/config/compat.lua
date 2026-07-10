-- ================================================================================================
-- TITLE : compatibility shims
-- ABOUT : small compatibility layer for plugins that lag behind Neovim nightly API changes.
-- ================================================================================================

-- Some plugins still reference APIs that moved or disappeared on Neovim nightly.
-- Revisit after plugin updates; this file should shrink rather than become permanent config.

vim.F = vim.F or {}
-- Used by plugins after vim.F.npcall is removed from Neovim.
if not vim.F.npcall then
	vim.F.npcall = function(fn, ...)
		return (function(ok, ...)
			if ok then
				return ...
			end
		end)(pcall(fn, ...))
	end
end

if vim.lsp and not vim.lsp.get_buffers_by_client_id then
	-- Used by older LSP-adjacent plugins that have not moved to client.attached_buffers.
	vim.lsp.get_buffers_by_client_id = function(client_id)
		local client = vim.lsp.get_client_by_id(client_id)
		if not client or not client.attached_buffers then
			return {}
		end

		return vim.tbl_keys(client.attached_buffers)
	end
end
