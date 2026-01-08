#!/usr/bin/env zsh
# Git and GitHub aliases

# `git` aliases

command -v "hub" &>/dev/null && {
    alias git=hub
}

alias acp="git add -A && git commit -v && git push"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# `lazygit` aliases

command -v "lazygit" &>/dev/null && {
    alias lg="lazygit"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# `cz` commitizen - Simple commit conventions for internet citizens.
# see: https://commitizen.github.io/cz-cli/

command -v "npx" &>/dev/null && {
    alias cz="npx cz"
}
