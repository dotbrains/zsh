#------------------#
# Section: General #
#------------------#

# Label: Editor
# Description: Open file in default editor.
# Parameters: $1 (optional) - The file path.
e() {
    if [ -z "$1" ]; then
        $EDITOR -- # Open editor at current path
        return 0
    fi

    # Check if the path exists
    if [ ! -e "$1" ]; then
        printf "%s\n" "ERROR: File does not exist."
        return 1
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - -

    cd "$(dirname "$1")" || return 1 # cd to the path
    $EDITOR --                       # Open editor at the path
}

# Label: Tab to Space
# Description: Convert file from tab to space indendation.
# Parameters: $1 (required) - The file to convert, $2 (optional) - The number of spaces, default: 2.
t2s() {
    if [[ "$2" ]]; then
        local number_of_spaces=$2
    else
        local number_of_spaces=2
    fi

    if [[ "$1" ]]; then
        local temp_file=$(mktemp -t tabs_to_spaces) || {
            printf "\n%s\n" "ERROR: Unable to create temporary file."
            return
        }
        expand -t "$number_of_spaces" "$1" >"$temp_file"
        cat "$temp_file" >"$1"
        printf "%s\n" "Converted: $1."
        rm -f "$temp_file"
    else
        printf "%s\n" "ERROR: File must be supplied."
        return 1
    fi
}

# Label: Colorized Type
# Description: Identical to "type" system command but with Bat support.
# Parameters: $1 (required) - The alias or function to inspect source code for.
cype() {
    local name="$1"

    if [[ -n "$name" ]]; then
        type "$name" | cat --language "bash"
    fi
}

# Label: Environment Update
# Description: Update environment with latest software.
# Updates Linux apps, brew, npm, fish, fisher, omf, pip, pip3 and their installed packages.
function u() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt upgrade -y
        sudo apt dist-upgrade -y
        sudo apt full-upgrade -y
        sudo apt autoremove -y
        sudo apt clean
    fi

    if command -v "brew" &>/dev/null; then
        brew update
        brew upgrade

        if [ "$(uname)" = "Darwin" ]; then
            brew update --cask

            if command -v "mas" &>/dev/null; then
                mas upgrade
            fi
        fi

        brew cleanup
    fi

    if command -v "basher" &>/dev/null; then
        basher update
    fi

    if command -v "fish" &>/dev/null; then
        fish -c "type -q fisher && \
			fisher && \
			fisher self-update"

        fish -c "type -q omf && \
			omf update"

        fish -c "fish_update_completions"
    fi

    if command -v "npm" &>/dev/null; then
        sudo npm i -g npm@latest

        if command -v "npm-check" &>/dev/null; then
            npm-check --global --update-all
        fi
    fi

    if command -v "pip3" &>/dev/null; then
        pip3 install -U pip
    fi

    if command -v "pip" &>/dev/null; then
        pip install --quiet --user --upgrade pip
        pip install --quiet --user --upgrade setuptools

        if command -v "pip-review" &>/dev/null; then
            pip-review -a
        fi
    fi

    if [[ -d "$HOME/.vim/plugins/Vundle.vim" ]]; then
        vim +PluginUpdate +qall
    fi
}

