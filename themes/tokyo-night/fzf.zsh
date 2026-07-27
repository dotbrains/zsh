#!/usr/bin/env zsh
# Generated from modules/colorschemes/themes/tokyo-night.toml.

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#c0caf5,bg:#1a1b26,hl:#e0af68
    --color=fg+:#c0caf5,bg+:#414868,hl+:#e0af68
    --color=info:#7aa2f7,prompt:#f7768e,pointer:#9ece6a
    --color=marker:#7dcfff,spinner:#bb9af7,header:#7dcfff'
fi
