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

## Design Boundaries

- The command line stays native. Avoid plugins that take over `cmdline` or `messages`.
- Notifications use `Snacks.notifier`; Noice is intentionally not part of the active plugin spec.
- Oil is the editable directory buffer. nvim-tree is the persistent project tree.
- Format-on-save skips special, non-modifiable, readonly, Markdown, text, and git commit buffers.
- Language support is centralized in `lua/config/tools.lua`; LSP servers, Mason tools, Treesitter parsers, formatters, and linters are derived from that file.
- Dashboard animation is disabled automatically in headless, small, or non-UI sessions.

## Version

This config targets modern Neovim and is currently validated with Neovim 0.13.

## License

This config is released under GPLv3.
