#!/usr/bin/env zsh
# Completions configuration

# Load completions
autoload -Uz compinit && compinit

# Only run zinit cdreplay if zinit is available
if command -v zinit &>/dev/null; then
    zinit cdreplay -q
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview "ls --color $realpath"
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview "ls --color $realpath"
