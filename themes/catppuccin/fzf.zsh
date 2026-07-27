#!/usr/bin/env zsh
# Generated from modules/colorschemes/themes/catppuccin.toml.

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#cad3f5,bg:#24273a,hl:#eed49f
    --color=fg+:#a5adcb,bg+:#5b6078,hl+:#eed49f
    --color=info:#8aadf4,prompt:#ed8796,pointer:#a6da95
    --color=marker:#8bd5ca,spinner:#f5bde6,header:#8bd5ca'
fi
