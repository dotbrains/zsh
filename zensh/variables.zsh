# Sets necessary PATH defaults
export PATH="$PATH:/usr/local/bin /usr/bin /bin /sbin /usr/sbin /usr/local/sbin /sbin $HOME/.fig/bin $HOME/.local/bin $HOME/.local/bin/tmux-session $HOME/.local/bin/etcher-cli /home/linuxbrew/.linuxbrew/bin /snap/bin $HOME/set-me-up $HOME/set-me-up/set-me-up-installer"

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
