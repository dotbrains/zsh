#!/usr/bin/env zsh

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#d3c6aa,bg:#2d353b,hl:#7fbbb3
    --color=fg+:#d3c6aa,bg+:#3a515d,hl+:#7fbbb3
    --color=info:#d699b6,prompt:#e67e80,pointer:#a7c080
    --color=marker:#83c092,spinner:#d699b6,header:#83c092'
fi
