#!/usr/bin/env zsh
# Package manager aliases

# Shorter commands for the `Node Package Manager`

# alias n="npm" # Do not use if using 'n' for Node version control
command -v "npm" &>/dev/null && {
    alias npmi='npm i -g'
    alias npmr='npm uninstall -g'
    alias npmls='npm list -g --depth 0'
    alias npms='npm s'
    alias npmu='npm i -g npm@latest'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Shorter commands for the `Yarn Package Manager`

command -v "yarn" &>/dev/null && {
    alias yr='yarn remove'
    alias ya='yarn add'
    alias yu='yarn self-update && yarn upgrade && yarn upgrade-interactive'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Shorter commands for `Homebrew`.

if command -v brew &>/dev/null; then
    alias brewd='brew doctor'
    alias brewi='brew install'
    alias brewr='brew uninstall'
    alias brews='brew search'

    # Function for updating and upgrading brew
    brewu() {
        brew upgrade
        brew cleanup

        if [ "$(uname)" = "Darwin" ]; then
            brew cask upgrade

            if command -v mas &>/dev/null; then
                # Update Mac App Store apps
                mas upgrade
            fi
        fi
    }
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Shorter commands for the `pip`

command -v "pip" &>/dev/null && {
    alias pipi='pip install'
    alias pipr='pip uninstall'
    alias pipls='pip list'
    alias pips='pip search'
    alias pipu="sudo pip install --upgrade pip \
                    && sudo pip install --upgrade setuptools \
                    && sudo pip-review --auto"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Shorter commands for the `pip3`

command -v "pip3" &>/dev/null && {
    alias pip3i='pip3 install'
    alias pip3r='pip3 uninstall'
    alias pip3ls='pip3 list'
    alias pip3s='pip3 search'
    alias pip3u="sudo pip3 install -U pip \
                    && sudo -H pip3 install -U pip \
                    && sudo pip-review --auto"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Shorter commands for `Composer`

command -v "composer" &>/dev/null && {
    alias ci='composer install'
    alias cr='composer remove'
    alias cls='composer list'
    alias cs='composer search'
    alias cu='composer self-update'
}
