-- ================================================================================================
-- TITLE : blink.cmp
-- ABOUT : Completion engine for LSP, path, snippets, buffer words, and lazydev Lua metadata.
-- LINKS :
--   > github : https://github.com/Saghen/blink.cmp
-- ================================================================================================

return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	lazy = false,
	opts = {
		keymap = {
			preset = "none",
			["<C-Space>"] = { "show", "hide" },
			["<CR>"] = { "accept", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<C-e>"] = { "hide", "fallback" },
			["<Tab>"] = { "snippet_forward", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "fallback" },
		},
		appearance = {
			nerd_font_variant = "mono",
		},
		cmdline = {
			enabled = false,
		},
		completion = {
			list = {
				selection = {
					preselect = false,
					auto_insert = false,
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 300,
			},
			menu = {
				auto_show = function()
					return vim.bo.filetype ~= "markdown"
				end,
			},
		},
		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		signature = {
			enabled = true,
		},
		fuzzy = {
			implementation = "prefer_rust",
			prebuilt_binaries = {
				download = true,
			},
		},
	},
}
