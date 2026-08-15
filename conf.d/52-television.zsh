#!/usr/bin/env zsh
# Initialize television (Ctrl-T autocomplete only).
# Ctrl-R stays owned by atuin -- tv's default Ctrl-R history binding is
# stripped here to avoid the two tools fighting over the same key.
# see: https://github.com/alexpasmantier/television
if command -v tv &>/dev/null; then
  eval "$(tv init zsh | grep -vF "bindkey '^R'")"
fi
