#!/usr/bin/env zsh
# Cursor Agent aliases
# see: https://cursor.com/docs/agent/cli

command -v "agent" &>/dev/null && {
    alias ca='agent --yolo'
    alias cap='agent -p'
}
