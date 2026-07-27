#!/usr/bin/env zsh
# Generated from modules/colorschemes/themes/solarized.toml.

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#839496,bg:#002b36,hl:#657b83
    --color=fg+:#fdf6e3,bg+:#002b36,hl+:#657b83
    --color=info:#839496,prompt:#cb4b16,pointer:#586e75
    --color=marker:#93a1a1,spinner:#6c71c4,header:#93a1a1'
fi
