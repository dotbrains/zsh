#!/usr/bin/env zsh
# Generated from modules/colorschemes/themes/dracula.toml.

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#f8f8f2,bg:#282a36,hl:#ffffa5
    --color=fg+:#ffffff,bg+:#6272a4,hl+:#ffffa5
    --color=info:#d6acff,prompt:#ff6e6e,pointer:#69ff94
    --color=marker:#a4ffff,spinner:#ff92df,header:#a4ffff'
fi
