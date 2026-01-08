#!/usr/bin/env zsh
# Local overrides and machine-specific configuration

# Load local zsh configurations if they exist
# This file allows you to add machine-specific settings without modifying
# the main configuration files.

# XDG-compliant local config
[[ -s "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local.zsh" ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/local.zsh"

# Backwards compatibility with old location
[[ -s "$HOME/.zsh.local" ]] && source "$HOME/.zsh.local"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# SDKMAN integration
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if command -v sdk &>/dev/null; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
