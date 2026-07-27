#!/usr/bin/env zsh

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#e0def4,bg:#191724,hl:#9ccfd8
    --color=fg+:#e0def4,bg+:#393552,hl+:#9ccfd8
    --color=info:#c4a7e7,prompt:#eb6f92,pointer:#31748f
    --color=marker:#ebbcba,spinner:#c4a7e7,header:#ebbcba'
fi
