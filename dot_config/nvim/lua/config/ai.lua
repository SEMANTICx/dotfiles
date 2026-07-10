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

local function copilot_auth_available()
	if vim.env.GITHUB_TOKEN and vim.env.GITHUB_TOKEN ~= "" and vim.env.CODESPACES and vim.env.CODESPACES ~= "" then
		return true
	end

	local config_root = vim.env.CODECOMPANION_TOKEN_PATH
		or vim.env.XDG_CONFIG_HOME
		or vim.fn.expand("~/.config")
	local auth_dir = vim.fs.joinpath(config_root, "github-copilot")

	for _, filename in ipairs({ "hosts.json", "apps.json" }) do
		local path = vim.fs.joinpath(auth_dir, filename)
		if vim.fn.filereadable(path) == 1 then
			local ok, lines = pcall(vim.fn.readfile, path)
			local decoded_ok, data = pcall(vim.json.decode, ok and table.concat(lines, " ") or "")
			if decoded_ok and type(data) == "table" then
				for host, credentials in pairs(data) do
					if type(host) == "string"
						and host:find("github.com", 1, true)
						and type(credentials) == "table"
						and type(credentials.oauth_token) == "string"
						and credentials.oauth_token ~= ""
					then
						return true
					end
				end
			end
		end
	end

	local database = vim.fs.joinpath(auth_dir, "auth.db")
	if vim.fn.filereadable(database) == 1 and vim.fn.executable("sqlite3") == 1 then
		local result = vim.system({
			"sqlite3",
			database,
			"SELECT token_ciphertext FROM oauth_tokens WHERE auth_authority == 'github.com' LIMIT 1",
		}, { text = true }):wait()
		return result.code == 0 and vim.trim(result.stdout or "") ~= ""
	end

	return false
end

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
	if M.adapter == "copilot" and not copilot_auth_available() then
		return "GitHub Copilot authentication (hosts.json, apps.json, or auth.db)"
	end

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
		string.format("Missing %s. Configure it or change CODECOMPANION_ADAPTER (current: %s)", env_name, M.adapter),
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
