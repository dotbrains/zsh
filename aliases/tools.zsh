#!/usr/bin/env zsh
# Tool-specific aliases

# piknik - Copy/paste anything over the network!
# see: https://github.com/jedisct1/piknik#suggested-shell-aliases

command -v "piknick" &>/dev/null && {
    # pkc : read the content to copy to the clipboard from STDIN
    alias pkc='piknik -copy'

    # pkp : paste the clipboard content
    alias pkp='piknik -paste'

    # pkm : move the clipboard content
    alias pkm='piknik -move'

    # pkz : delete the clipboard content
    alias pkz='piknik -copy < /dev/null'

    # pkpr : extract clipboard content sent using the pkfr command
    alias pkpr='piknik -paste | tar xzhpvf -'
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# has - checks presence of various command line tools and their versions on the path
# see: https://github.com/kdabir/has#running-directly-off-the-internet

alias has="curl -sL https://git.io/_has | bash -s"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# 'fzy' aliases

command -v "fzy" &>/dev/null && {
    alias fzyf="find . -type f | fzy"
    alias fzyd="find . -type d | fzy"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# thefuck - Magnificent app which corrects your previous console command.
# see: https://github.com/nvbn/thefuck/wiki/Shell-aliases#bash
command -v thefuck &>/dev/null && {
    eval "$(thefuck --alias)"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# `wttr` alias

alias wttr="curl wttr.in"
