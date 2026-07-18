-- ================================================================================================
-- TITLE : nvim-treesitter
-- ABOUT : Treesitter configurations and abstraction layer for Neovim.
-- NOTES : this has been updated for the latest treesitter api using branch "main"
-- LINKS :
--   > github : https://github.com/nvim-treesitter/nvim-treesitter
-- ================================================================================================

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	cmd = "TSInstallConfigured",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local treesitter = require("nvim-treesitter")
		local tools = require("config.tools")

		treesitter.setup({
			install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
		})

		local function missing_parsers()
			local config = require("nvim-treesitter.config")
			local already_installed = config.get_installed("parsers")
			local parsers = {}

			for _, parser in ipairs(tools.treesitter_parsers) do
				if not vim.tbl_contains(already_installed, parser) then
					table.insert(parsers, parser)
				end
			end

			return parsers
		end

		vim.api.nvim_create_user_command("TSInstallConfigured", function()
			local parsers = missing_parsers()
			if #parsers == 0 then
				vim.notify("All configured Treesitter parsers are installed", vim.log.levels.INFO)
				return
			end
			treesitter.install(parsers)
		end, { desc = "Install missing configured Treesitter parsers" })

		local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			callback = function(args)
				if
					vim.list_contains(treesitter.get_installed("parsers"), vim.treesitter.language.get_lang(args.match))
				then
					vim.treesitter.start(args.buf)
				end
			end,
		})
	end,
}
