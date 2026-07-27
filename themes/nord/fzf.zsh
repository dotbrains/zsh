#!/usr/bin/env zsh
# Generated from modules/colorschemes/themes/nord.toml.

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#d8dee9,bg:#2e3440,hl:#ebcb8b
    --color=fg+:#eceff4,bg+:#4c566a,hl+:#ebcb8b
    --color=info:#81a1c1,prompt:#bf616a,pointer:#a3be8c
    --color=marker:#8fbcbb,spinner:#b48ead,header:#8fbcbb'
fi
