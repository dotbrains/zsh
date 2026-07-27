#!/usr/bin/env zsh

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
    --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
    --color=info:#ff79c6,prompt:#ff5555,pointer:#50fa7b
    --color=marker:#8be9fd,spinner:#ff79c6,header:#8be9fd'
fi
