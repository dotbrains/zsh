#!/usr/bin/env zsh

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#839496,bg:#002b36,hl:#268bd2
    --color=fg+:#93a1a1,bg+:#073642,hl+:#268bd2
    --color=info:#6c71c4,prompt:#dc322f,pointer:#859900
    --color=marker:#2aa198,spinner:#6c71c4,header:#2aa198'
fi
