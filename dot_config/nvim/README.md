# Neovim Configuration

## Overview

This config is optimized for a stable terminal-first Neovim workflow with native cmdline rendering, Snacks notifications, Oil directory editing, nvim-tree project browsing, LSP/completion, formatting, linting, Markdown notes, Rust debugging, and a custom Ghostty dashboard.

Supported languages and frameworks include: `typescript`, `javascript`, `python`, `go`, `lua`, `bash`, `c`, `cpp`, `json`, `yaml`, `dockerfile`, `html`, `css`, `tailwindcss`, `rust`, `solidity`, `vue`, `react`, `svelte`, and `markdown`.

## Maintenance

- `:ConfigHealth` checks the configuration boundary: Lazy spec, Mason tools, Treesitter parsers, formatter/linter executables, LSP configs, dashboard assets, AI adapter, and keymap conflicts.
- `:ConfigSyncTools` installs configured Mason tools and Treesitter parsers.
- `:TSInstallConfigured` installs only the Treesitter parsers declared by this config.
- `:CodeCompanionCheck` checks the configured AI adapter credentials.
- `:DashboardAnimationToggle` toggles the Ghostty dashboard animation at runtime.
- `nvim --headless "+lua dofile(vim.fn.stdpath('config') .. '/tests/ci.lua')"` runs the local regression suite.
- `nvim --headless "+lua dofile(vim.fn.stdpath('config') .. '/tests/lsp.lua')"` verifies real `lua_ls`, `pyright`, and `ts_ls` attachment and protocol responses when their executables are installed.
- `nvim --headless "+lua dofile(vim.fn.stdpath('config') .. '/tests/toolchain.lua')"` validates installed Mason tools, Treesitter parsers, and representative formatter/linter executions after `:ConfigSyncTools`.

GitHub Actions restores plugins strictly from `lazy-lock.json`, verifies that restoration does not rewrite the lockfile, and runs the fast regression suite against stable and nightly Neovim on every push and pull request. The stable job also installs three representative language servers and verifies real attachment plus an LSP protocol round trip. A weekly and manually dispatchable job installs the complete declared toolchain and runs the deeper toolchain checks. Actions are pinned to immutable commits, while Dependabot proposes weekly GitHub Actions updates.

## Design Boundaries

- The command line stays native. Avoid plugins that take over `cmdline` or `messages`.
- Notifications use `Snacks.notifier`; Noice is intentionally not part of the active plugin spec.
- Oil is the editable directory buffer. nvim-tree is the persistent project tree.
- Format-on-save skips special, non-modifiable, readonly, Markdown, text, and git commit buffers.
- Lint runs immediately after save and is debounced for 300 ms after leaving insert mode. Override the delay with `vim.g.lint_debounce_ms`.
- Node, Python, Ruby, and Perl remote plugin providers are disabled; external tools and language servers remain available.
- Language support is centralized in `lua/config/tools.lua`; LSP servers, Mason tools, Treesitter parsers, formatters, and linters are derived from that file.
- Obsidian uses `~/Documents/Notes` by default. Set `OBSIDIAN_VAULT` to use a different vault without editing the config.
- Dashboard animation is disabled automatically in headless or non-UI sessions, pauses while Neovim is unfocused, and can be toggled at runtime. Override its 50 ms frame interval with `vim.g.dashboard_animation_interval`.

## Version

This config targets modern Neovim and is currently validated with Neovim 0.13.

## License

This config is released under GPLv3.
