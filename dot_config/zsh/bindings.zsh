# =========================================================
# Keybindings
# =========================================================

# Keep Atuin scoped to explicit history search. The built-in bindings are
# disabled so Up/Down continue to use zsh-history-substring-search.
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-ctrl-r --disable-up-arrow --disable-ai)"

  # Keep existing zsh history as the primary inline suggestion source. Atuin
  # only fills in when the local history strategy has no matching command.
  ZSH_AUTOSUGGEST_STRATEGY=(history atuin)
fi

# Open the current command line in $VISUAL/$EDITOR, then return the edited text
# to the prompt without executing it.
autoload -Uz edit-command-line
zle -N edit-command-line

# Cursor shape per vi mode
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

# Disable command mode line highlight
ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# zsh-vi-mode resets all bindings on init, so custom bindings
# must be registered via this hook to survive.
zvm_after_init() {
  # Ctrl+Right -> move forward one word (^[[1;5C is the terminal escape code)
  bindkey '^[[1;5C' forward-word

  # Ctrl+Left -> move backward one word (^[[1;5D is the terminal escape code)
  bindkey '^[[1;5D' backward-word

  # Ctrl+F -> fzf file picker (no hidden files)
  bindkey '^F' _fzf_file_no_hidden

  # Ctrl+\ -> toggle autosuggestions (useful for screen recordings)
  bindkey '^\' autosuggest-toggle

  # Up/Down -> history search by substring (^[[A/^[[B are up/down arrow escape codes)
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

  # Ctrl-R -> Atuin history search in either vi mode. Atuin returns the chosen
  # command to the prompt for review because enter_accept is disabled.
  if (( $+widgets[atuin-search-viins] )); then
    bindkey -M viins '^R' atuin-search-viins
    bindkey -M vicmd '^R' atuin-search-vicmd
  fi

  # Ctrl-X Ctrl-E -> edit the current command in Neovim.
  bindkey -M viins '^X^E' edit-command-line
  bindkey -M vicmd '^X^E' edit-command-line

  # zsh-vi-mode resets keymaps after plugins load, so restore fzf-git's
  # Ctrl-G chords for files, branches, tags, commits, stashes, and worktrees.
  if (( $+functions[__fzf_git_init] )); then
    __fzf_git_init files branches tags remotes hashes stashes lreflogs each_ref worktrees
  fi
}
