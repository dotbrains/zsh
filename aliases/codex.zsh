#!/usr/bin/env zsh
# Codex CLI aliases
# see: https://developers.openai.com/codex

command -v "codex" &>/dev/null && {
    alias codex='codex --model o3'
}
