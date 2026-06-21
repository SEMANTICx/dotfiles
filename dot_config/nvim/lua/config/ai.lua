local M = {}

M.adapter = vim.env.CODECOMPANION_ADAPTER or "copilot"
M.model = vim.env.CODECOMPANION_MODEL

local required_env_by_adapter = {
	anthropic = "ANTHROPIC_API_KEY",
	azure_openai = "AZURE_OPENAI_API_KEY",
	deepseek = "DEEPSEEK_API_KEY",
	gemini = "GEMINI_API_KEY",
	githubmodels = "GITHUB_TOKEN",
	huggingface = "HUGGINGFACE_API_KEY",
	jina = "JINA_API_KEY",
	mistral = "MISTRAL_API_KEY",
	novita = "NOVITA_API_KEY",
	openai = "OPENAI_API_KEY",
	openai_responses = "OPENAI_API_KEY",
	openrouter = "OPENROUTER_API_KEY",
	tavily = "TAVILY_API_KEY",
	xai = "XAI_API_KEY",
}

local function adapter_spec()
	if M.model and M.model ~= "" then
		return {
			name = M.adapter,
			model = M.model,
		}
	end

	return M.adapter
end

function M.missing_credentials()
	local env_name = required_env_by_adapter[M.adapter]
	if not env_name or (vim.env[env_name] ~= nil and vim.env[env_name] ~= "") then
		return nil
	end

	return env_name
end

function M.has_credentials()
	return M.missing_credentials() == nil
end

function M.notify_missing_credentials()
	local env_name = M.missing_credentials()
	if not env_name then
		return false
	end

	vim.notify(
		string.format("Set %s or change CODECOMPANION_ADAPTER. Current adapter: %s", env_name, M.adapter),
		vim.log.levels.WARN,
		{ title = "CodeCompanion" }
	)
	return true
end

function M.run(command)
	return function()
		if M.notify_missing_credentials() then
			return
		end
		vim.cmd(command)
	end
end

function M.opts()
	return {
		interactions = {
			chat = {
				adapter = adapter_spec(),
			},
			inline = {
				adapter = adapter_spec(),
			},
			cmd = {
				adapter = adapter_spec(),
			},
		},
	}
end

function M.setup_commands()
	vim.api.nvim_create_user_command("CodeCompanionCheck", function()
		if M.notify_missing_credentials() then
			return
		end

		vim.notify(
			string.format("CodeCompanion adapter ready: %s", M.adapter),
			vim.log.levels.INFO,
			{ title = "CodeCompanion" }
		)
	end, { desc = "Check CodeCompanion adapter credentials" })
end

return M
