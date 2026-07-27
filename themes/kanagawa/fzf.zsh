#!/usr/bin/env zsh

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#dcd7ba,bg:#1f1f28,hl:#7e9cd8
    --color=fg+:#dcd7ba,bg+:#2d4f67,hl+:#7e9cd8
    --color=info:#957fb8,prompt:#c34043,pointer:#76946a
    --color=marker:#7aa89f,spinner:#957fb8,header:#7aa89f'
fi
