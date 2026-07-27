#!/usr/bin/env zsh
# Catppuccin dircolors fallback.
# Reuse gruvbox LS_COLORS until a dedicated Catppuccin map exists.

if [[ -r "$ZSH_CONFIG_DIR/themes/gruvbox/dircolors.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/themes/gruvbox/dircolors.zsh"
fi
