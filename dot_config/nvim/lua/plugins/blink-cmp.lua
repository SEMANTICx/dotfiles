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
	event = { "BufReadPre", "BufNewFile", "InsertEnter" },
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
				window = {
					border = "rounded",
					max_width = 70,
					max_height = 18,
					desired_min_width = 45,
					desired_min_height = 8,
				},
			},
			menu = {
				min_width = 28,
				max_height = 12,
				border = "rounded",
				scrollbar = false,
				auto_show = function()
					return vim.bo.filetype ~= "markdown"
				end,
				draw = {
					padding = { 1, 1 },
					gap = 1,
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", gap = 1 },
						{ "kind" },
					},
					components = {
						kind_icon = {
							text = function(ctx)
								local icons = require("nvchad.icons.lspkind")
								return icons[ctx.kind] or "󰈚"
							end,
						},
						kind = {
							ellipsis = false,
							width = { max = 14 },
							text = function(ctx)
								return ctx.kind
							end,
							highlight = function(ctx)
								return ctx.kind_hl
							end,
						},
					},
				},
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
			window = {
				border = "rounded",
				max_width = 80,
				max_height = 10,
			},
		},
		fuzzy = {
			implementation = "prefer_rust",
			prebuilt_binaries = {
				download = true,
			},
		},
	},
}
