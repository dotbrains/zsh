#!/usr/bin/env zsh
# zensh - A Zen ZSH Configuration
# see: https://github.com/dotbrains/zsh
# This configuration prioritizes zen and calm in order to reduce
# distractions and maintain momentum when working inside of the terminal.

# Unset fish-specific environment variables to prevent conflicts
unset STARSHIP_SHELL

# Get the directory where this script is located
ZSH_CONFIG_DIR="${${(%):-%x}:A:h}"

# Set XDG base directories if not already set
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Create XDG directories if they don't exist
[[ ! -d "$XDG_DATA_HOME/zsh" ]] && mkdir -p "$XDG_DATA_HOME/zsh"
[[ ! -d "$XDG_STATE_HOME/zsh" ]] && mkdir -p "$XDG_STATE_HOME/zsh"
[[ ! -d "$XDG_CACHE_HOME/zsh" ]] && mkdir -p "$XDG_CACHE_HOME/zsh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Source all configuration files from conf.d/
# Files are sourced in numerical order (00-*, 10-*, etc.)
for config_file in "$ZSH_CONFIG_DIR"/conf.d/*.zsh; do
    [ -f "$config_file" ] && source "$config_file"
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Source all alias files
for alias_file in "$ZSH_CONFIG_DIR"/aliases/*.zsh; do
    [ -f "$alias_file" ] && source "$alias_file"
done

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Source all function files
for function_file in "$ZSH_CONFIG_DIR"/functions/*.zsh; do
    [ -f "$function_file" ] && source "$function_file"
done

# Source git functions subdirectory
for git_function in "$ZSH_CONFIG_DIR"/functions/git/*.zsh; do
    [ -f "$git_function" ] && source "$git_function"
done
