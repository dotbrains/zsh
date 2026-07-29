#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$repo_root"

find . -type f \( -name '*.zsh' -o -name '*.sh' \) -not -path '*/.git/*' -print0 |
    xargs -0 -r zsh -n
printf "OK zsh syntax\\n"
