#!/usr/bin/env zsh
# Gruvbox Dark Medium theme for fzf
# see: https://github.com/morhetz/gruvbox

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#d5c4a1,bg:#282828,hl:#fabd2f
    --color=fg+:#ebdbb2,bg+:#3c3836,hl+:#fabd2f
    --color=info:#83a598,prompt:#fb4934,pointer:#b8bb26
    --color=marker:#8ec07c,spinner:#d3869b,header:#8ec07c'
fi
