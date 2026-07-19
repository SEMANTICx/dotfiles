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
	custom_openai = "CODECOMPANION_CUSTOM_URL",
	tavily = "TAVILY_API_KEY",
	xai = "XAI_API_KEY",
}

local rotating_key_env_by_adapter = {
	openrouter = {
		multiple = "OPENROUTER_API_KEYS",
		single = "OPENROUTER_API_KEY",
	},
	custom_openai = {
		multiple = "CODECOMPANION_CUSTOM_API_KEYS",
		single = "CODECOMPANION_CUSTOM_API_KEY",
	},
}

local key_cursor = {}

local function parse_api_keys(value)
	local keys = {}
	local seen = {}

	for key in (value or ""):gmatch("[^,;\r\n]+") do
		key = vim.trim(key)
		if key ~= "" and not seen[key] then
			seen[key] = true
			table.insert(keys, key)
		end
	end

	return keys
end

local function api_keys(adapter)
	local env_names = rotating_key_env_by_adapter[adapter]
	if not env_names then
		return {}
	end

	local keys = parse_api_keys(vim.env[env_names.multiple])
	if #keys == 0 then
		keys = parse_api_keys(vim.env[env_names.single])
	end

	return keys
end

local function next_api_key(adapter)
	local keys = api_keys(adapter)
	if #keys == 0 then
		return ""
	end

	local cursor = (key_cursor[adapter] or 0) % #keys + 1
	key_cursor[adapter] = cursor
	return keys[cursor]
end

local function openrouter_adapter()
	return require("codecompanion.adapters").extend("openrouter", {
		env = {
			api_key = function()
				return next_api_key("openrouter")
			end,
		},
	})
end

local function custom_openai_adapter()
	return require("codecompanion.adapters").extend("openai_compatible", {
		formatted_name = "Custom OpenAI-compatible",
		env = {
			api_key = function()
				return next_api_key("custom_openai")
			end,
			url = vim.env.CODECOMPANION_CUSTOM_URL,
			chat_url = vim.env.CODECOMPANION_CUSTOM_CHAT_URL or "/v1/chat/completions",
			models_endpoint = vim.env.CODECOMPANION_CUSTOM_MODELS_ENDPOINT or "/v1/models",
		},
	})
end

local function copilot_auth_available()
	if vim.env.GITHUB_TOKEN and vim.env.GITHUB_TOKEN ~= "" and vim.env.CODESPACES and vim.env.CODESPACES ~= "" then
		return true
	end

	local config_root = vim.env.CODECOMPANION_TOKEN_PATH or vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")
	local auth_dir = vim.fs.joinpath(config_root, "github-copilot")

	for _, filename in ipairs({ "hosts.json", "apps.json" }) do
		local path = vim.fs.joinpath(auth_dir, filename)
		if vim.fn.filereadable(path) == 1 then
			local ok, lines = pcall(vim.fn.readfile, path)
			local decoded_ok, data = pcall(vim.json.decode, ok and table.concat(lines, " ") or "")
			if decoded_ok and type(data) == "table" then
				for host, credentials in pairs(data) do
					if
						type(host) == "string"
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

	local required_env = required_env_by_adapter[M.adapter]
	if type(required_env) == "string" then
		required_env = { required_env }
	end

	for _, env_name in ipairs(required_env or {}) do
		if vim.env[env_name] == nil or vim.env[env_name] == "" then
			return env_name
		end
	end

	local key_env = rotating_key_env_by_adapter[M.adapter]
	if key_env and #api_keys(M.adapter) == 0 then
		return string.format("%s or %s", key_env.multiple, key_env.single)
	end

	return nil
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
		adapters = {
			http = {
				openrouter = openrouter_adapter,
				custom_openai = custom_openai_adapter,
			},
		},
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

		local key_count = #api_keys(M.adapter)
		local key_status = ""
		if key_count > 0 then
			key_status = string.format(" (%d API key%s)", key_count, key_count == 1 and "" or "s")
		end

		vim.notify(
			string.format("CodeCompanion adapter ready: %s%s", M.adapter, key_status),
			vim.log.levels.INFO,
			{ title = "CodeCompanion" }
		)
	end, { desc = "Check CodeCompanion adapter credentials" })
end

return M
