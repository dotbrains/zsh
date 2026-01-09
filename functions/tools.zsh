#!/usr/bin/env zsh
# Tool functions (overmind, asciinema)


#---------------------------------------------#
# Section: [asciinema](https://asciinema.org) #
#---------------------------------------------#

# Label: asciinema Record
# Description: Create new asciinema recording.
# Parameters: $1 (required) - The recording label.
cinr() {
    local label="$1"
    local name="${label,,}.cast"

    if [[ -z "$label" ]]; then
        printf "%s\n" "ERROR: Recording label is missing."
        return 1
    fi

    asciinema rec --title "$label" "$name"
}

#-----------------------------------------------------------#
# Section: [Overmind](https://github.com/DarthSim/overmind) #
#-----------------------------------------------------------#

# Label: Overmind Start
# Description: Start processes.
# Parameters: $1 (optional) - Port. Default: 2990.
oms() {
    local port=${2:-2990}
    overmind start --port "$port" --port-step 10
}

# Label: Overmind Connect
# Description: Connect to running process.
# Parameters: $1 (optional) - Process. Default: "web".
omc() {
    local process="${1:-web}"
    overmind connect "$process"
}

# Label: Overmind Restart
# Description: Restart running process.
# Parameters: $1 (optional) - Process. Default: "web".
omr() {
    local process="${1:-web}"
    overmind restart "$process"
}

#---------------------------------------------------------------#
# Section: [emoji-log](https://github.com/ahmadawais/Emoji-Log) #
#---------------------------------------------------------------#

if [[ -f "$HOME/.config/zsh/zensh/emoji-log.zsh" ]]; then
    . "$HOME/.config/zsh/zensh/emoji-log.zsh"
fi
