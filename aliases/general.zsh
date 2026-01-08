#!/usr/bin/env zsh
# General shell aliases

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias cd..="cd .."

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Shell shortcuts
alias :q="exit"
alias c="clear"
alias ch="history -c && > ~/.bash_history"
alias m="man"
alias path='printf "%b\n" "${PATH//:/\\n}"'
alias q="exit"
alias vim="nvim"

command -v "xclip" &>/dev/null && {
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
}

alias x="chmod +x"
alias z="zoxide"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# 'ls' aliases

alias ls="ls --color"

command -v "eza" &>/dev/null && {
    alias ls="eza"

    # List all files colorized in long format
    alias l="eza -l"
}

command -v "eza" &>/dev/null && {
    alias ll="eza -l -g --icons"
    alias lla="ll -a"
}

# List only directories
alias lsd="ls -lF --color | grep --color=never '^d'"
# List only hidden files
alias lsh="ls -ld .?*"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Network aliases

# Get local IP.
alias lip="ipconfig getifaddr en0"

# Get external IP.
alias xip="curl -s checkip.dyndns.org | grep -Eo \"[0-9\\.]+\""

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Better `rm`

# Option 1: `rip` - a safer and more user-friendly alternative to 'rm'
# see: https://github.com/nivekuil/rip

if command -v rip &>/dev/null; then
    alias rm="rip"
fi

# Option 2: `trash` - safer alternative to 'rm'
# see: https://github.com/andreafrancia/trash-cli

if command -v trash &>/dev/null; then
    alias rm="trash"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Lock screen.

# Check operating system type
case "$(uname)" in
Darwin)
    # MacOS alias
    alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
    ;;

Linux)
    # Check for gnome-screensaver-command
    if command -v gnome-screensaver-command &>/dev/null; then
        alias afk='gnome-screensaver-command -l'
    # Check for dm-tool
    elif command -v dm-tool &>/dev/null; then
        alias afk='dm-tool lock'
    fi
    ;;
esac

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Hide/Show desktop icons.

# Hide desktop icons
case "$(uname)" in
Darwin)
    alias hide-desktop-icons='defaults write com.apple.finder CreateDesktop -bool false; killall Finder'
    ;;

Linux)
    # For GNOME
    alias hide-desktop-icons='gsettings set org.gnome.desktop.background show-desktop-icons false'
    ;;
esac

# Show desktop icons
case "$(uname)" in
Darwin)
    alias show-desktop-icons='defaults write com.apple.finder CreateDesktop -bool true; killall Finder'
    ;;

Linux)
    # For GNOME
    alias show-desktop-icons='gsettings set org.gnome.desktop.background show-desktop-icons true'
    ;;
esac

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# update CLTs

command -v "fish" &>/dev/null && [ -f "$HOME/.config/fish/functions/update.fish" ] && {
    alias update="fish -c \"update\""
}
