#!/usr/bin/env zsh
# Utility functions

# Label: brew-update
# Description: Update Homebrew and installed packages.
brew-update() {
    if command -v "brew" &>/dev/null; then
        brew update
        brew upgrade

        if [ "$(uname)" = "Darwin" ]; then
            brew upgrade --cask

            if command -v "mas" &>/dev/null; then
                mas upgrade
            fi
        fi

        brew cleanup
    fi
}

# Label: ISO
# Description: Builds an ISO image from mounted volume.
# Parameters: $1 (required) - Volume source path. $2 (required) - ISO output file path.
iso() {
    local source_path="$1"
    local output_path="$HOME/Downloads/$2.iso"

    if [[ ! -d "$source_path" ]]; then
        printf "%s\n" "Source path must be supplied or doesn't exist: $source_path."
        return 1
    fi

    if [[ -z "$2" ]]; then
        printf "%s\n" "ISO file name must be supplied."
        return 1
    fi

    printf "%s\n" "Creating $output_path..."
    hdiutil makehybrid -iso -joliet -o "$output_path" "$source_path"
}

# Label: Kill Process
# Description: Kill errant/undesired process.
# Parameters: $1 (required) - The search query, $2 (optional) - The signal. Default: 15.
kilp() {
    local query="$1"
    local signal=${2:-15}

    pkill -"$signal" -l -f "$query"
}

# Bash: Kill Vim when “Vim: Warning: Output not to a terminal”
# see: https://stackoverflow.com/a/46432233/5290011
# vim() {
#     [ -t 1 ] &&
#         command vim "$@"
# }

# ghf - [G]rep [H]istory [F]or top ten commands and execute one
# usage:
#  Most frequent command in recent history
#   ghf
#  Most frequent instances of {command} in all history
#   ghf {command}
#  Execute {command-number} after a call to ghf
#   !! {command-number}
function latest-history { history | tail -n 50; }
function grepped-history { history | grep "$1"; }
function chop-first-column { awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'; }
function add-line-numbers { awk '{print NR " " $0}'; }
function top-ten { sort | uniq -c | sort -r | head -n 10; }
function unique-history { chop-first-column | top-ten | chop-first-column | add-line-numbers; }
function ghf {
    if [ $# -eq 0 ]; then latest-history | unique-history; fi
    if [ $# -eq 1 ]; then grepped-history "$1" | unique-history; fi
    if [ $# -eq 2 ]; then
        grepped-history "$1" | unique-history | grep ^"$2" | chop-first-column
    fi
}

# Search for text within the current directory.
qt() {
    grep -ir --color=always "$*" --exclude-dir=".git" --exclude-dir="node_modules" . | less -RX
    #     │└─ search all files under each directory, recursively
    #     └─ ignore case
}

# Create new directories and enter the first one.
mkd() {
    if [ -n "$*" ]; then

        mkdir -p "$@"
        #      └─ make parent directories if needed

        cd "$@" ||
            exit 1

    fi
}

# Human readable file size
# (because `du -h` doesn't cut it for me).
hrfs() {
    printf "%s" "$1" |
        awk '{
            i = 1;
            split("B KB MB GB TB PB EB ZB YB WTFB", v);
            value = $1;

            # confirm that the input is a number
            if ( value + .0 == value ) {

                while ( value >= 1024 ) {
                    value/=1024;
                    i++;
                }

                if ( value == int(value) ) {
                    printf "%d %s", value, v[i]
                } else {
                    printf "%.1f %s", value, v[i]
                }

            }
        }' |
        sed -e ":l" \
            -e "s/\([0-9]\)\([0-9]\{3\}\)/\1,\2/; t l"
    #    └─ add thousands separator
    #       (changes "1023.2 KB" to "1,023.2 KB")
}

# Get gzip information (gzipped file size + reduction size).
gz() {
    declare -i GZIPPED_SIZE=0
    declare -i ORIGINAL_SIZE=0

    if [ -f "$1" ]; then
        if [ -s "$1" ]; then

            ORIGINAL_SIZE=$(wc -c <"$1")
            printf "\n original size:   %12s\n" "$(hrfs "$ORIGINAL_SIZE")"

            GZIPPED_SIZE=$(gzip -c "$1" | wc -c)
            printf " gzipped size:    %12s\n" "$(hrfs "$GZIPPED_SIZE")"

            printf " ─────────────────────────────\n"
            printf " reduction:       %12s [%s%%]\n\n" \
                "$(hrfs $((ORIGINAL_SIZE - GZIPPED_SIZE)))" \
                "$(printf "%s" "$ORIGINAL_SIZE $GZIPPED_SIZE" |
                    awk '{ printf "%.1f", 100 - $2 * 100 / $1 }' |
                    sed -e "s/0*$//;s/\.$//")"
            #              └─ remove tailing zeros

        else
            printf "\"%s\" is empty.\n" "$1"
        fi
    else
        printf "\"%s\" is not a file.\n" "$1"
    fi
}

# extract any type of compressed file
function extract {
    echo Extracting "$1" ...
    if [ -f "$1" ]; then
        case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz) tar xzf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) rar x "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xf "$1" ;;
        *.tbz2) tar xjf "$1" ;;
        *.tgz) tar xzf "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Delete files that match a certain pattern from the current directory.
delete_files() {
    local q="${1:-*.DS_Store}"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    find . -type f -name "$q" -ls -delete
}

# Create data URI from a file.
datauri() {
    local mimeType=""

    if [ -f "$1" ]; then
        mimeType=$(file -b --mime-type "$1")
        #                └─ do not prepend the FILE to the output

        if [[ $mimeType == text/* ]]; then
            mimeType="$mimeType;charset=utf-8"
        fi

        printf "data:%s;base64,%s" \
            "$mimeType" \
            "$(openssl base64 -in "$1" | tr -d "\n")"
    else
        printf "%s is not a file.\n" "$1"
    fi
}

# check if a certain process is running
function is_running {
    declare -r PROCESS="$1"

    if pgrep -f "$PROCESS" >/dev/null; then
        echo "($PROCESS) is running"
    else
        echo "($PROCESS)" "is not running."
    fi
}

# Process phone images.
ppi() {
    command -v "convert" &>/dev/null ||
        exit 0

    declare query="${1:-*.jpg}"
    declare geometry="${2:-50%}"

    for i in $query; do

        if [[ "$(echo "${i##*.}" | tr '[:upper:]' '[:lower:]')" != "png" ]]; then
            imgName="${i%.*}.png"
        else
            imgName="_${i%.*}.png"
        fi

        convert "$i" \
            -colorspace RGB \
            +sigmoidal-contrast 11.6933 \
            -define filter:filter=Sinc \
            -define filter:window=Jinc \
            -define filter:lobes=3 \
            -sigmoidal-contrast 11.6933 \
            -colorspace sRGB \
            -background transparent \
            -gravity center \
            -resize "$geometry" \
            +append \
            "$imgName" &&
            printf "* %s (%s)\n" \
                "$imgName" \
                "$geometry"

    done
}

# Label: Print Black on White
# Description: Print black text on a white background.
# Parameters: $1 (required) - Content to print.
_print_black_on_white() {
    local content="$1"
    printf "\e[0;30m\e[48;5;255m$content\033[m"
}

# Label: Clip and Print
# Description: Copy input to clipboard and print what what was copied (best used with a pipe).
# Parameters: $1 (optional) - Displays "(copied to cliboard)" on a new line. Default: false.
_copy_and_print() {
    local delimiter=${1:-' '}
    local message="$delimiter(copied to clipboard)\n"

    pbcopy && printf "%s" "$(pbpaste)" && printf "$message"
}

# Label: Toggle Total Color
# Description: Format and conditionally color the total.
# Parameters: $1 (required) - The total, $2(required) - The label, $3 (required) - The color.
_toggle_total_color() {
    local total="$1"
    local label="$2"
    local color="$3"

    if [[ $total -gt 0 ]]; then
        printf "$color$total $label\033[m"
    else
        printf "$total $label"
    fi
}

#-------------------------------------------------------------------------------#
# Section: [piknik](https://github.com/jedisct1/piknik#suggested-shell-aliases) #
#-------------------------------------------------------------------------------#

# pko <content> : copy <content> to the clipboard
pko() {
    if command -v "piknik" &>/dev/null; then
        echo "$*" | piknik -copy
    else
        echo "(piknik) is not installed"
    fi
}

# pkf <file> : copy the content of <file> to the clipboard
pkf() {
    if command -v "piknik" &>/dev/null; then
        piknik -copy <"$1"
    else
        echo "(piknik) is not installed"
    fi
}

# pkfr [<dir>] : send a whole directory to the clipboard, as a tar archive
pkfr() {
    if command -v "piknik" &>/dev/null; then
        tar czpvf - "${1:-.}" | piknik -copy
    else
        echo "(piknik) is not installed"
    fi
}

#----------------------------------------------#
# Section: [transfer.sh](https://transfer.sh/) #
#----------------------------------------------#

transfer() {
    if [ $# -eq 0 ]; then
        echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"
        return 1
    fi

    tmpfile=$(mktemp -t transferXXX)

    if tty -s; then
        basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
        curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >>"$tmpfile"
    else
        curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >>"$tmpfile"
    fi

    cat "$tmpfile"

    rm -f "$tmpfile"
}

#-----------------------------------------------------------#
# Section: [less](http://en.wikipedia.org/wiki/Less_(Unix)) #
#-----------------------------------------------------------#

# Label: Less Interactive
# Description: Inspect file, interactively.
# Parameters: $1 (required) - The file path.
lessi() {
    if [[ "$1" ]]; then
        less +F --LONG-PROMPT --LINE-NUMBERS --RAW-CONTROL-CHARS --QUIET --quit-if-one-screen -i "$1"
    else
        printf "%s\n" "ERROR: File path must be supplied."
        printf "%s\n" "TIP: Use CONTROL+c to switch to VI mode, SHIFT+f to switch back, and CONTROL+c+q to exit."
    fi
}
