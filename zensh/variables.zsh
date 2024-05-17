# Sets necessary PATH defaults
DEFAULT_PATHS=(
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/sbin"
    "/usr/sbin"
    "/usr/local/sbin"
    "$HOME/.fig/bin"
    "$HOME/.local/bin"
    "$HOME/.local/bin/tmux-session"
    "$HOME/.local/bin/etcher-cli"
    "$HOME/set-me-up"
    "$HOME/set-me-up/set-me-up-installer"
)

# Add each default path to PATH
for path in "${DEFAULT_PATHS[@]}"; do
    export PATH="$PATH:$path"
done

# Check if we are on Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    LINUX_PATHS=(
        "/home/linuxbrew/.linuxbrew/bin"
        "/snap/bin"
    )

    # Add each Linux-specific path to PATH
    for path in "${LINUX_PATHS[@]}"; do
        export PATH="$PATH:$path"
    done
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Nord for fzf
# see: https://github.com/ianchesal/nord-fzf
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#e5e9f0,bg:#3b4252,hl:#81a1c1
    --color=fg+:#e5e9f0,bg+:#3b4252,hl+:#81a1c1
    --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
    --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'

# Nord for Bat
export BAT_THEME="Nord"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Dotfiles directory
export DOTFILES=$HOME/"set-me-up"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Configure Neovim as default editor
export EDITOR="nvim"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Prefer US English and use UTF-8 encoding.

export LANG="en_US"
export LC_ALL="en_US.UTF-8"
