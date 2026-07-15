local M = {}

local function format_buffer(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local conform_ok, conform = pcall(require, "conform")
	if conform_ok then
		conform.format({ bufnr = bufnr, timeout_ms = 2000, lsp_format = "fallback" })
	else
		vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
	end
end

local function notify_lsp_error(prefix, err)
	local detail = type(err) == "table" and (err.message or vim.inspect(err)) or tostring(err)
	vim.notify(prefix .. ": " .. detail, vim.log.levels.ERROR, { title = "LSP" })
end

local function command_handler_type(client, command)
	local name = command.command
	if (client.commands and client.commands[name]) or vim.lsp.commands[name] then
		return "local"
	end

	local provider = client.server_capabilities.executeCommandProvider
	if type(provider) == "table" and vim.list_contains(provider.commands or {}, name) then
		return "server"
	end
end

local function execute_command(client, bufnr, command, done)
	if command_handler_type(client, command) == "server" then
		client:exec_cmd(command, { bufnr = bufnr }, function(err)
			if err then
				notify_lsp_error("Organize imports command failed", err)
			end
			done()
		end)
		return
	end

	client:exec_cmd(command, { bufnr = bufnr })
	done()
end

local function apply_code_action(client, bufnr, action, done)
	local function apply(resolved)
		if resolved.edit then
			vim.lsp.util.apply_workspace_edit(resolved.edit, client.offset_encoding)
		end

		local action_command = resolved.command
		if action_command then
			local command = type(action_command) == "table" and action_command or resolved
			execute_command(client, bufnr, command, done)
		else
			done()
		end
	end

	local is_command = type(action.title) == "string" and type(action.command) == "string"
	local needs_resolve = not is_command
		and not (action.edit and action.command)
		and client:supports_method("codeAction/resolve", bufnr)

	if not needs_resolve then
		apply(action)
		return
	end

	local resolved = false
	local function complete_resolve(err, resolved_action)
		if resolved then
			return
		end
		resolved = true
		if err then
			notify_lsp_error("Organize imports resolve failed", err)
			apply(action)
			return
		end
		apply(resolved_action or action)
	end

	local success = client:request("codeAction/resolve", action, complete_resolve, bufnr)
	if success == false then
		complete_resolve({ message = client.name .. " rejected the code action resolve request" })
	end
end

local function select_code_action(actions, callback)
	if #actions == 0 then
		callback()
		return
	end
	if #actions == 1 then
		callback(actions[1])
		return
	end

	vim.ui.select(actions, {
		prompt = "Organize imports:",
		format_item = function(item)
			return string.format("%s [%s]", item.action.title, item.client.name)
		end,
	}, callback)
end

function M.run(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local method = "textDocument/codeAction"
	local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
	local pending = #clients
	local actions = {}

	local function apply_selected(item)
		if not item then
			format_buffer(bufnr)
			return
		end
		apply_code_action(item.client, bufnr, item.action, function()
			format_buffer(bufnr)
		end)
	end

	if pending == 0 then
		format_buffer(bufnr)
		return
	end

	for _, client in ipairs(clients) do
		local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
		params.context = {
			only = { "source.organizeImports" },
			diagnostics = {},
			triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked,
		}

		local completed = false
		local function complete_request(err, result)
			if completed then
				return
			end
			completed = true

			if err then
				notify_lsp_error("Organize imports request failed", err)
			end
			for _, action in ipairs(result or {}) do
				if not action.disabled then
					actions[#actions + 1] = { action = action, client = client }
				end
			end

			pending = pending - 1
			if pending == 0 then
				select_code_action(actions, apply_selected)
			end
		end

		local success = client:request(method, params, complete_request, bufnr)
		if success == false then
			complete_request({ message = client.name .. " rejected the organize imports request" })
		end
	end
end

return M
