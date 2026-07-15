-- ================================================================================================
-- TITLE : NvChad UI
-- LINKS :
--   > github : https://github.com/NvChad/ui
-- ABOUT : Load NvChad's real statusline renderer without taking over the rest of the UI.
-- ================================================================================================

local use_nvchad_statusline = vim.g.statusline_backend == "nvchad"
local dependencies = { "nvim-tree/nvim-web-devicons" }

if use_nvchad_statusline then
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		{
			"NvChad/base46",
			build = function()
				require("base46").load_all_highlights()
			end,
		},
	}
end

return {
	"NvChad/ui",
	lazy = false,
	dependencies = dependencies,
	config = function()
		require("nvim-web-devicons").setup({
			default = true,
			override = require("nvchad.icons.devicons"),
		})

		if not use_nvchad_statusline then
			return
		end

		local cache = vim.g.base46_cache .. "statusline"

		local function apply_highlights()
			if vim.uv.fs_stat(cache) then
				dofile(cache)
			else
				require("base46").load_all_highlights()
			end

			local groups = {
				StatusLine = { bg = "#22262E" },
				StatusLineNC = { bg = "#1E222A" },
				St_ChadFileIcon = { fg = "#ABB2BF", bg = "#2D3139" },
				St_ChadFile = { fg = "#ABB2BF", bg = "#2D3139" },
				St_ChadFileSep = { fg = "#2D3139", bg = "#22262E" },
				St_ChadProjectOuter = { fg = "#343A44", bg = "#22262E" },
				St_ChadProjectSep = { fg = "#E06C75", bg = "#343A44" },
				St_ChadProjectIcon = { fg = "#1E222A", bg = "#E06C75" },
				St_ChadProjectText = { fg = "#ABB2BF", bg = "#2D3139" },
				St_ChadGitAdd = { fg = "#98C379", bg = "#22262E" },
				St_ChadGitChange = { fg = "#E5C07B", bg = "#22262E" },
				St_ChadGitDelete = { fg = "#E06C75", bg = "#22262E" },
				St_ChadDiagnosticError = { fg = "#E06C75", bg = "#22262E", bold = true },
				St_ChadDiagnosticWarn = { fg = "#E5C07B", bg = "#22262E", bold = true },
				St_ChadDiagnosticHint = { fg = "#56B6C2", bg = "#22262E" },
				St_ChadDiagnosticInfo = { fg = "#61AFEF", bg = "#22262E" },
				St_ChadLsp = { fg = "#81A1C1", bg = "#22262E" },
				St_ChadBranch = { fg = "#5C6370", bg = "#22262E" },
				St_ChadPositionOuterJoined = { fg = "#3B414B", bg = "#2D3139" },
				St_ChadPositionOuterSolo = { fg = "#3B414B", bg = "#22262E" },
				St_ChadPositionSep = { fg = "#98C379", bg = "#3B414B" },
				St_ChadPositionIcon = { fg = "#1E222A", bg = "#98C379" },
				St_ChadPositionText = { fg = "#98C379", bg = "#2D3139" },
			}

			local mode_colors = {
				Normal = "#81A1C1",
				Visual = "#C678DD",
				Insert = "#98C379",
				Terminal = "#56B6C2",
				NTerminal = "#E5C07B",
				Replace = "#E06C75",
				Confirm = "#56B6C2",
				Command = "#E5C07B",
				Select = "#61AFEF",
			}

			for name, color in pairs(mode_colors) do
				groups["St_Chad" .. name .. "ModeLeft"] = { fg = "#1E222A", bg = color, bold = true }
				groups["St_Chad" .. name .. "ModeLeftSep"] = { fg = color, bg = "#2D3139" }
			end

			for name, value in pairs(groups) do
				vim.api.nvim_set_hl(0, name, value)
			end
		end

		apply_highlights()
		vim.o.statusline = "%!v:lua.require('nvchad.stl.default')()"

		local group = vim.api.nvim_create_augroup("NvChadStatusline", { clear = true })
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = group,
			callback = function()
				vim.schedule(apply_highlights)
			end,
			desc = "Restore NvChad statusline highlights after colorscheme changes",
		})
	end,
}
