# Ensure we start with the system default PATH
DEFAULT_SYSTEM_PATHS="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Sets necessary PATH defaults
DEFAULT_PATHS=(
    "$HOME/.local/bin"
    "$HOME/set-me-up"
    "$HOME/set-me-up/set-me-up-installer"
)

# Linux-specific PATH additions
LINUX_PATHS=(
    "/home/linuxbrew/.linuxbrew/bin"
    "/snap/bin"
)

# Reset PATH to default system paths
export PATH="$DEFAULT_SYSTEM_PATHS"

# Add paths to PATH if they exist
add_paths() {
    for path in "$@"; do
        [ -d "$path" ] && export PATH="$PATH:$path"
    done
}

# Add default paths
add_paths "${DEFAULT_PATHS[@]}"

# Add Linux-specific paths if on Linux
[[ "$OSTYPE" == "linux-gnu"* ]] && add_paths "${LINUX_PATHS[@]}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Ruby configurations
# Adds "GEMS_PATH" to "$PATH"
# Fixes "I INSTALLED GEMS WITH --user-install AND THEIR COMMANDS ARE NOT AVAILABLE"
# see: https://guides.rubygems.org/faqs/#user-install

if command -v gem &>/dev/null; then
    if [ -d "$(gem environment gemdir)/bin" ]; then
        export PATH="$(gem environment gemdir)/bin:$PATH"
    fi
fi

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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Make Python use UTF-8 encoding for output to stdin/stdout/stderr.

export PYTHONIOENCODING="UTF-8"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Don't clear the screen after quitting a `man` page.

export MANPAGER="less -X"
