#!/usr/bin/env zsh
# Cursor Agent CLI aliases
# see: https://cursor.com/docs/agent/cli

command -v "agent" &>/dev/null && {
    alias ca='agent --force'
    alias cap='agent -p'
}
