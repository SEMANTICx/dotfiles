local function has_lean_toolchain()
	return vim.fn.executable("lake") == 1 or vim.fn.executable("lean") == 1
end

return {
	"Julian/lean.nvim",
	enabled = has_lean_toolchain,
	ft = "lean",
	opts = {
		mappings = false,
		abbreviations = { enable = true, leader = "\\" },
		infoview = { autoopen = true },
	},
	config = function(_, opts)
		require("lean").setup(opts)

		local function set_keymaps(bufnr)
			local function map(lhs, command, desc)
				vim.keymap.set("n", lhs, "<cmd>" .. command .. "<cr>", {
					buffer = bufnr,
					silent = true,
					desc = "Lean: " .. desc,
				})
			end

			-- LocalLeader is Space in this config, so keep Lean under a dedicated
			-- <leader>l namespace rather than shadowing global mappings.
			map("<localleader>li", "LeanInfoviewToggle", "toggle infoview")
			map("<localleader>lt", "LeanGotoInfoview", "go to infoview")
			map("<localleader>lp", "LeanInfoviewPinTogglePause", "pause infoview")
			map("<localleader>lx", "LeanInfoviewAddPin", "add pin")
			map("<localleader>lc", "LeanInfoviewClearPins", "clear pins")
			map("<localleader>ls", "LeanInfoviewAcceptSuggestion", "accept suggestion")
			map("<localleader>lr", "LeanRestartFile", "restart server")
			map([[<localleader>l\]], "LeanAbbreviationsReverseLookup", "reverse symbol lookup")
		end

		local group = vim.api.nvim_create_augroup("LeanKeymaps", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = "lean",
			callback = function(args)
				set_keymaps(args.buf)
			end,
		})
		if vim.bo.filetype == "lean" then
			set_keymaps(0)
		end
	end,
}
