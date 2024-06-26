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

#---------------------------------------------------------------------#
# Section: [License Finder](https://github.com/pivotal/LicenseFinder) #
#---------------------------------------------------------------------#

# Label: License Finder (include)
# Description: Include license in global list.
# Parameters: $1 (required) - License, $2 (required) - Why.
licensei() {
    local license="$1"
    local why="$2"

    if [[ -z "$license" ]]; then
        printf "%s\n" "ERROR: Must supply license."
        return 1
    fi

    if [[ -z "$why" ]]; then
        printf "%s\n" "ERROR: Explain why the license is safe."
        return 1
    fi

    license_finder whitelist add "$license" --who "$(git config user.name)" --why "$why"
}

# Label: License Finder (add)
# Description: Adds library to global list.
# Parameters: $1 (required) - Library, $2 (required) - Why.
licensea() {
    local library="$1"
    local why="$2"

    if [[ -z "$library" ]]; then
        printf "%s\n" "ERROR: Must supply library."
        return 1
    fi

    if [[ -z "$why" ]]; then
        printf "%s\n" "ERROR: Explain why the license is safe."
        return 1
    fi

    license_finder approval add "$library" --who "$(git config user.name)" --why "$why"
}

#-----------------------------------------#
# Section: [OpenSSL](https://openssl.org) #
#-----------------------------------------#

# Label: SSL Certificate Creation
# Description: Create SSL certificate.
# Parameters: $1 (required) - The domain name.
sslc() {
    local name="$1"

    if [[ -z "$name" ]]; then
        printf "%s\n" "ERROR: Domain name for SSL certificate must be supplied."
        return 1
    fi

    cat >"$name.cnf" <<-EOF
  [req]
  distinguished_name = req_distinguished_name
  x509_extensions = v3_req
  prompt = no
  [req_distinguished_name]
  CN = *."$name"
  [v3_req]
  keyUsage = keyEncipherment, dataEncipherment
  extendedKeyUsage = serverAuth
  subjectAltName = @alt_names
  [alt_names]
  DNS.1 = *."$name"
  DNS.2 = "$name"
EOF

    openssl req \
        -new \
        -newkey rsa:2048 \
        -sha256 \
        -days 3650 \
        -nodes \
        -x509 \
        -keyout "$name.key" \
        -out "$name.crt" \
        -config "$name.cnf"

    rm -f "$name.cnf"
}

#--------------------------------------#
# Section: [curl](http://curl.haxx.se) #
#--------------------------------------#

# Label: Curl Inspect
# Description: Inspect remote file with default editor.
# Parameters: $1 (required) - The URL.
curli() {
    if [[ "$1" ]]; then
        local file=$(mktemp -t suspicious_curl_file) || {
            printf "%s\n" "ERROR: Unable to create temporary file."
            return
        }
        curl --location --fail --silent --show-error "$1" >"$file" || {
            printf "%s\n" "Failed to curl file."
            return
        }
        $EDITOR --wait "$file" || {
            printf "Unable to open temporary curl file.\n"
            return
        }
        rm -f "$file"
    else
        printf "%s\n" "ERROR: URL must be supplied."
        return 1
    fi
}

# Label: Curl Diagnostics
# Description: Curl with diagnostic information for request.
# Parameters: $1 (required) - The URL.
curld() {
    local url="$1"

    printf -v diagnostics "%s\n" "\n" \
        "HTTP Version:   %{http_version}" \
        "HTTP Status:    %{http_code}" \
        "Content Type:   %{content_type}" \
        "DNS Lookup:     %{time_namelookup} seconds" \
        "Connect:        %{time_connect} seconds" \
        "App Connect:    %{time_appconnect} seconds" \
        "Pre-Transfer:   %{time_pretransfer} seconds" \
        "Start Transfer: %{time_starttransfer} seconds" \
        "Speed:          %{speed_upload}↑ %{speed_download}↓ bytes/second" \
        "Total Time:     %{time_total} seconds" \
        "Total Size:     %{size_download} bytes"

    curl --write-out "$diagnostics" --url "$url"
}

#--------------------------------------------------#
# Section: [lsof](http://people.freebsd.org/~abe/) #
#--------------------------------------------------#

# Label: Port
# Description: List file activity on given port.
# Parameters: $1 (required) - The port number.
port() {
    if [[ "$1" ]]; then
        sudo lsof -i :"$1"
    else
        printf "%s\n" "ERROR: Port number must be supplied."
    fi
}

#------------------------------------#
# Section: [Git](http://git-scm.com) #
#------------------------------------#

# Label: Git Init (all)
# Description: Initialize/re-initialize repositories in current directory.
gia() {
    while read -r project; do
        (
            cd "$project" || exit
            if [[ -d ".git" ]]; then
                printf "\033[36m${project}\033[m: " # Print project (cyan) and message (white).
                git init
            fi
        )
    done < <(ls -A1)
}

# Label: Git Safe
# Description: Marks repository as safe for auto-loading project's `bin/*` on path.
gafe() {
    if [[ -d ".git" ]]; then
        mkdir -p .git/safe
        printf "%s\n" "Repository has been marked safe."
        exec /usr/local/bin/bash
    fi
}

# Label: Git Root
# Description: Change to repository root directory regardless of current depth.
groot() {
    cd "$(git rev-parse --show-toplevel)" || exit
}

# Label: Git Info
# Description: Print repository overview information.
ginfo() {
    printf "\n%s\n\n" "$(_print_black_on_white ' Local Configuration (.git/config) ')"
    git config --local --list

    printf "\n%s\n\n" "$(_print_black_on_white ' Stashes ')"
    local stashes="$(gashl)"
    if [[ -n "$stashes" ]]; then
        printf "%s\n" "$stashes"
    else
        printf "%s\n" "None."
    fi

    printf "\n%s\n\n" "$(_print_black_on_white ' Branches ')"
    gbl

    printf "\n%s\n\n" "$(_print_black_on_white ' Remote URLs ')"
    git remote --verbose

    printf "\n%s\n\n" "$(_print_black_on_white ' File Churn (Top 25) ')"
    ghurn | head -n 25

    printf "\n%s\n\n" "$(_print_black_on_white ' Commits by Author ')"
    guthors

    printf "\n%s\n\n" "$(_print_black_on_white ' Total Commits ')"
    gount

    printf "\n%s\n\n" "$(_print_black_on_white ' Last Tag ')"
    _git_last_tag_info

    printf "\n%s\n\n" "$(_print_black_on_white ' Last Commit ')"
    git show --decorate --stat

    printf "\n%s\n\n" "$(_print_black_on_white ' Current Status ')"
    git status --short --branch
}

# Label: Git Statistics
# Description: Answer statistics for current project.
gstats() {
    if [[ -d ".git" ]]; then
        gount
        printf "Branches: %s\n" "$(_git_branch_list | wc -l | tr -d ' ')"
        printf "Tags: %s\n" "$(git tag | wc -l | tr -d ' ')"
        printf "Stashes: %s\n" "$(_git_stash_count)"
        printf "Size: %s\n" "$(git count-objects --human-readable)"
    fi
}

# Label: Git Statistics (all)
# Description: Answer statistics for all projects in current directory.
gstatsa() {
    while read -r project; do
        (
            cd "$project" || exit
            printf "\033[36m${project}\033[m:\n" # Print project (cyan) and message (white).
            gstats
        )
    done < <(ls -A1)
}

# Label: Git Churn
# Description: Answer commit churn for project files (sorted highest to lowest).
ghurn() {
    git log --all --find-renames --find-copies --name-only --format='format:' "$@" |
        sort |
        grep --invert-match '^$' |
        uniq -c |
        sort |
        awk '{print $1 "\t" $2}' |
        sort --general-numeric-sort --reverse |
        more
}

# Label: Git Commit Count
# Description: Answer total number of commits for current project.
gount() {
    printf "Commits: "
    git rev-list --count HEAD
}

# Label: Git Log (interactive)
# Description: List feature branch commits with support to show/diff individual commits.
gli() {
    local commits=($(_git_branch_shas))
    _git_commit_options "${commits[*]}"

    read -p "Enter selection: " response
    if [[ "$response" == 'q' ]]; then
        return
    fi

    local selected_commit=${commits[$((response - 1))]}
    printf "%s\n" "$(_git_show_details "$selected_commit")"

    printf "\n"
    read -p "View diff (y = yes, n = no)? " response
    if [[ "$response" == 'y' ]]; then
        gdt "$selected_commit"^!
    fi
}

# Label: Git Log Details
# Description: Dynamically list commit details for current feature branch or entire master branch.
gld() {
    if [[ _git_branch_name != "master" ]]; then
        commits=($(_git_branch_shas))

        if [[ ${#commits[@]} == 1 ]]; then
            _git_show_details "${commits[0]}"
        elif [[ ${#commits[@]} > 1 ]]; then
            range="${commits[-1]}^..${commits[0]}"
            git log --stat --pretty=format:"$(_git_log_details_format)" "$range"
        fi
    fi
}

# Label: Git Show
# Description: Show commit details with optional diff support.
# Parameters: $1 (optional) - The commit to show. Default: <last commit>, $2 (optional) - Launch difftool. Default: false.
ghow() {
    local commit="$1"
    local difftool="$2"

    if [[ -n "$commit" && -n "$difftool" ]]; then
        _git_show_details "$commit"
        git difftool "$commit^" "$commit"
    elif [[ -n "$commit" && -z "$difftool" ]]; then
        _git_show_details "$commit"
    else
        _git_show_details
    fi
}

# Label: Git File
# Description: Show file details for a specific commit (with optional diff support).
# Parameters: $1 (required) - The file, $2 (required) - The commit, $3 (optional) - Launch difftool. Default: false.
gile() {
    local file="$1"
    local commit="$2"
    local diff="$3"

    if [[ -z "$file" ]]; then
        printf "%s\n" "ERROR: File is missing."
        return 1
    fi

    if [[ -z "$commit" ]]; then
        printf "%s\n" "ERROR: Commit SHA is missing."
        return 1
    fi

    git show --stat --pretty=format:"$(_git_log_details_format)" "$commit" -- "$file"

    if [[ -n "$diff" ]]; then
        gdt "$commit"^! -- "$file"
    fi
}

# Label: Git File History
# Description: View file commit history (with optional diff support).
# Parameters: $1 (required) - The file path.
gistory() {
    if [[ -z "$1" ]]; then
        printf "%s\n" "ERROR: File must be supplied."
        return 1
    fi

    local file="$1"
    local commits=($(git rev-list --reverse HEAD -- "$file"))

    _git_file_commits commits[@] "$file"
}

# Label: Git Blame History
# Description: View file commit history for a specific file and/or lines (with optional diff support).
# Parameters: $1 (required) - The file path, $2 (optional) - The file lines (<start>,<end>).
glameh() {
    if [[ -z "$1" ]]; then
        printf "%s\n" "ERROR: File must be supplied."
        return 1
    fi

    local file="$1"
    local lines="$2"
    local commits=($(git blame -s -M -C -C -L "$lines" "$file" | awk '{print $1}' | sort -u))

    _git_file_commits commits[@] "$file"
}

# Label: Git Authors (all)
# Description: Answer author commit activity per project (ranked highest to lowest).
guthorsa() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                # Print project (cyan) and message (white).
                printf "\033[36m${project}\033[m:\n"
                guthors
            fi
        )
    done < <(ls -A1)
}

# Label: Git Author Contributions
# Description: Answers total lines added/removed by author for repo (with emphasis on deletion).
# Parameters: $1 (optional) - Author name. Default: Current user.
guthorc() {
    local author="${1:-$(git config --get user.name)}"

    if [[ -z "$author" ]]; then
        printf "%s\n" "ERROR: Author name required."
        return 1
    fi

    git log --author="$author" --pretty=tformat: --numstat |
        awk -v author="$author" \
            'BEGIN {
    initial_pattern = "\033[1;34m%s\033[0m: Added: \033[0;31m%s\033[0m, Removed: \033[0;32m%s\033[0m, "
    positive_pattern = initial_pattern "Total: \033[0;32m%s\033[0m.\n";
    neutral_pattern = initial_pattern "Total: %s.\n";
    negative_pattern = initial_pattern "Total: \033[0;31m%s\033[0m.\n";
  }
  {
    added += $1;
    removed += $2;
    total += $1 - $2;
  }
  END {
    if (total > 0)
      printf negative_pattern, author, added, removed, total
    else if (total < 0)
      printf positive_pattern, author, added, removed, total
    else
      printf neutral_pattern, author, added, removed, total
  }'
}

# Label: Git Status (all)
# Description: Answer status of projects with uncommited/unpushed changes.
gsa() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                # Capture current project status info as an array.
                local results=($(git status --short --branch))
                local size=${#results[@]}

                # Print Git activity if Git activity detected (white).
                if [[ $size -gt 2 ]]; then
                    # Remove first and second elements since they contain branch info.
                    results=("${results[@]:1}")
                    results=("${results[@]:1}")

                    # Print project (cyan).
                    printf "\033[36m${project}\033[m:\n"

                    # Print results (white).
                    for line in "${results[@]}"; do
                        printf "%s" "$line "
                        if [[ $newline == 1 ]]; then
                            printf "\n"
                            local newline=0
                        else
                            local newline=1
                        fi
                    done
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Update
# Description: Fetch commits, prune untracked references, review each commit (optional, with diff), and pull (optional).
gup() {
    git fetch --quiet
    commits=($(git log --reverse --no-merges --pretty=format:"%h" ..@{upstream}))

    if [[ ${#commits[@]} == 0 ]]; then
        printf "%s\n" "All is quiet, nothing to update."
        return 0
    fi

    printf "%s\n" "Commit Summary:"
    hr '-'
    git log --reverse --no-merges --pretty=format:"$(_git_log_line_format)" ..@{upstream}
    hr '-'

    printf "%s\n" "Commit Review (↓${#commits[@]}):"

    local counter=1
    for commit in "${commits[@]}"; do
        hr '-'
        printf "[$counter/${#commits[@]}] "
        counter=$((counter + 1))

        _git_show_details "$commit"

        printf "\n"
        read -p "View Diff (y = yes, n = no, q = quit)? " response

        case $response in
        'y')
            git difftool "$commit"^!
            ;;
        'n') ;;
        'q') ;;
        *)
            printf "%s\n" "ERROR: Invalid option."
            ;;
        esac

        break
    done

    hr '-'
    read -p "Commit Pull (y/n)? " response

    if [[ "$response" == 'y' ]]; then
        git pull
    fi
}

# Label: Git Sync
# Description: Syncs up remote changes and deletes pruned/merged branches.
# Parameters
gync() {
    if [[ $(_git_branch_name) != "master" ]]; then
        printf "%s\n" "ERROR: Whoa, switch to master branch first."
        return 1
    fi

    git pull && gbdm
}

# Label: Git Set Config Value (all)
# Description: Set key value for projects in current directory.
# Parameters: $1 (required) - The key name, $2 (required) - The key value.
gseta() {
    if [[ "$1" && "$2" ]]; then
        while read -r project; do
            (
                cd "$project" || exit

                if [[ -d ".git" ]]; then
                    # Set key value for current project.
                    git config "$1" "$2"

                    # Print project (cyan) and email (white).
                    printf "\033[36m${project}\033[m: $1 = $2\n"
                fi
            )
        done < <(ls -A1)
    else
        printf "%s\n" "ERROR: Key and value must be supplied."
        return 1
    fi
}

# Label: Git Get Config Value (all)
# Description: Answer key value for projects in current directory.
# Parameters: $1 (required) - The key name.
ggeta() {
    if [[ "$1" ]]; then
        while read -r project; do
            (
                cd "$project" || exit

                if [[ -d ".git" ]]; then
                    # Get Git config value for given key.
                    local result=$(git config "$1")

                    # Print project (cyan).
                    printf "\033[36m${project}\033[m: "

                    # Print result.
                    if [[ -n "$result" ]]; then
                        printf "$1 = $result\n" # White
                    else
                        printf "\033[31mKey not found.\033[m\n" # Red
                    fi
                fi
            )
        done < <(ls -A1)
    else
        printf "%s\n" "ERROR: Key must be supplied."
        return 1
    fi
}

# Label: Git Unset (all)
# Description: Unset key value for projects in current directory.
# Parameters: $1 (required) - The key name.
gunseta() {
    if [[ "$1" ]]; then
        while read -r project; do
            (
                cd "$project" || exit

                if [[ -d ".git" ]]; then
                    # Unset key for current project with error output suppressed.
                    git config --unset "$1" &>/dev/null

                    # Print project (cyan).
                    printf "\033[36m${project}\033[m: \"$1\" key removed.\n"
                fi
            )
        done < <(ls -A1)
    else
        printf "%s\n" "ERROR: Key must be supplied."
        return 1
    fi
}

# Label: Git Email Set (all)
# Description: Sets user email for projects in current directory.
# Parameters: $1 (required) - The email address.
gailsa() {
    gseta "user.email" "$1"
}

# Label: Git Email Get
# Description: Answer user email for current project.
gail() {
    if [[ -d ".git" ]]; then
        git config user.email
    fi
}

# Label: Git Email Get (all)
# Description: Answer user email for projects in current directory.
gaila() {
    ggeta "user.email"
}

# Label: Git Since
# Description: Answer summarized list of activity since date/time for projects in current directory.
# Parameters: $1 (required) - The date/time since value, $2 (optional) - The date/time until value, $3 (optional) - The commit author.
gince() {
    if [[ "$1" ]]; then
        while read -r project; do
            (
                cd "$project" || exit

                if [[ -d ".git" ]]; then
                    # Capture git log activity.
                    local results=$(git log --oneline --color --format="$(_git_log_line_format)" --since "$1" --until "$2" --author "$3" --reverse)
                    # Print project name (cyan) and Git activity (white) only if Git activity was detected.
                    if [[ -n "$results" ]]; then
                        printf "\033[36m${project}:\033[m\n$results\n"
                    fi
                fi
            )
        done < <(ls -A1)
    else
        printf "%s\n" "ERROR: Date/time must be supplied."
        return 1
    fi
}

# Label: Git Day
# Description: Answer summarized list of current day activity for projects in current directory.
gday() {
    gince "12am"
}

# Label: Git Week
# Description: Answer summarized list of current week activity for projects in current directory.
gweek() {
    gince "last Monday 12am"
}

# Label: Git Month
# Description: Answer summarized list of current month activity for projects in current directory.
gmonth() {
    gince "1 month 12am"
}

# Label: Git Standup
# Description: Answer summarized list of activity since yesterday for projects in current directory.
gsup() {
    gince "yesterday.midnight" "midnight" $(git config user.name)
}

# Label: Git Tail
# Description: Answer commit history since last tag for current project (copies results to clipboard).
gtail() {
    if [[ ! -d ".git" ]]; then
        printf "%s\n" "ERROR: Not a Git repository."
        return 1
    fi

    if [[ $(_git_commits_since_last_tag) ]]; then
        _git_commits_since_last_tag | _copy_and_print "\n"
    else
        printf "%s\n" "No commits since last tag."
    fi
}

# Label: Git Tail (all)
# Description: Answer commit history count since last tag for projects in current directory.
gtaila() {
    # Iterate through root project directories.
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                local info=$(_git_commit_count_since_last_tag "$project")
                if [[ ! "$info" == *": 0"* ]]; then
                    printf "%s\n" "$info"
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Stash
# Description: Creates stash.
# Parameters: $1 (optional) - Label. Default: "Last Actions (YYYY-MM-DD HH:MM:SS AM|PM Z)."
gash() {
    local label=${1:-"Last Actions ($(date '+%Y-%m-%d %r %Z'))."}
    git stash push --include-untracked --message "$label"
}

# Label: Git Stash List
# Description: List stashes.
gashl() {
    git stash list --pretty=format:'%C(magenta)%gd%C(reset) %C(yellow)%h%C(reset) %s %C(green)(%cr)%C(reset)'
}

# Label: Git Stash Show
# Description: Show stash or prompt for stash to show.
# Parameters: $1 (optional) - Show git diff. Default: skipped.
gashs() {
    local stash=($(git stash list))
    local diff_option="$1"

    if [[ -n "$diff_option" ]]; then
        case "$diff_option" in
        'd')
            _process_git_stash "git stash show --patch" "Git Stash Diff Options (select stash to diff)"
            ;;
        't')
            _process_git_stash "git difftool" "Git Stash Diff Options (select stash to diff)"
            ;;
        *)
            printf "%s\n\n" "Usage: gashs OPTION"
            printf "%s\n" "Available options:"
            printf "%s\n" "  d: Git diff."
            printf "%s\n" "  t: Git difftool."
            return
            ;;
        esac
    else
        _process_git_stash "_git_show_details" "Git Stash Show Options (select stash to show)"
    fi
}

# Label: Git Stash Pop
# Description: Pop stash or prompt for stash to pop.
gashp() {
    _process_git_stash "git stash pop" "Git Stash Pop Options (select stash to pop)"
}

# Label: Git Stash Drop
# Description: Drop stash or prompt for stash to drop.
gashd() {
    _process_git_stash "git stash drop" "Git Stash Drop Options (select stash to drop)"
}

# Label: Git Stash (all)
# Description: Answer stash count for projects in current directory.
gasha() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                local count=$(_git_stash_count)

                if [[ -n $count && $count != 0 ]]; then
                    printf "\033[36m${project}\033[m: $count\n" # Outputs in cyan color.
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Upstream Commit Count (all)
# Description: Answer upstream commit count since last pull for projects in current directory.
gucca() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                # Capture upstream project commit count.
                git fetch --quiet
                local count=$(git log ..@{upstream} --pretty=format:"%h" | wc -l | tr -d ' ')

                if [[ $count -gt '0' ]]; then
                    # Print project (cyan) and commit count (white).
                    printf "\033[36m${project}\033[m: $count\n"
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Pull (all)
# Description: Pull new changes from remote branch for projects in current directory.
gpua() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                # Capture current project status.
                local results=$(git pull | tail -1)

                # Print project name and Git activity only if Git activity was detected.
                printf "\033[36m${project}\033[m: " # Outputs in cyan color.

                if [[ -n "$results" && "$results" != "Already up-to-date." ]]; then
                    printf "\n  %s\n" "$results"
                else
                    printf "✓\n"
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Add (all)
# Description: Apply file changes (including new files) for projects in current directory.
galla() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                # Apply all changes to Git.
                local results=$(git add --verbose --all .)

                # Print project name (cyan) and Git activity (white) only if Git activity was detected.
                if [[ -n "$results" ]]; then
                    printf "\033[36m${project}\033[m:\n$results\n"
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Commit Breakpoint
# Description: Create a breakpoint (empty) commit to denote related commits in a feature branch.
# Parameters: $1 (optional) - A custom label. Default: "Breakpoint"
gcb() {
    local label="${1:-Breakpoint}"
    git commit --allow-empty --no-verify --message "----- $label -----"
}

# Label: Git Commit Fix (interactive)
# Description: Select which commit to fix within current feature branch.
gcfi() {
    local commits=($(_git_branch_shas))

    _git_commit_options "${commits[*]}" "Select commit to fix"

    read -p "Enter selection: " response
    if [[ "$response" == 'q' ]]; then
        return
    fi

    printf "\n"
    local selected_commit=${commits[$((response - 1))]}
    gcf "$selected_commit"
}

# Label: Git Commit Fix (file)
# Description: Create commit fix for file (ignores previous fixups).
# Parameters: $1 (required) - The file to create fixup commit for.
gcff() {
    local file_path="$1"
    local file_sha="$(git log --grep 'fixup!' --invert-grep --pretty=format:%h -1 "$file_path")"

    if [[ "($(_git_branch_shas))" == *"$file_sha"* ]]; then
        git add "$file_path" && git commit --fixup "$file_sha"
    fi
}

# Label: Git Commit Fix and Push
# Description: Create fixup commit, push, and copy URL to clipboard.
# Parameters: $1 (required) - The commit SHA to be fixed, $2 (optional) - Use "-a" to amend the fixup message.
gcfp() {
    local sha="$1"
    local option="$2"

    if git diff --cached --quiet; then
        printf "%s\n" "ERROR: No staged changes detected."
        return 1
    fi

    if [[ -z "$sha" ]]; then
        printf "%s\n" "ERROR: Fixup commit SHA is required."
        return 1
    fi

    git commit --fixup "$sha"

    if [[ "$option" == "-a" ]]; then
        git commit --amend
    fi

    git push
    gh u $(_git_commit_last)
}

# Label: Git Commit (all)
# Description: Commit changes (unstaged and staged) for projects in current directory.
gcaa() {
    local temp_file=$(mktemp -t git-commit)
    cp "$HOME"/.config/git/commit_message.txt "$temp_file"
    $EDITOR --wait "$temp_file"

    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                # Only process projects that have changes.
                if [[ "$(git status --short)" ]]; then
                    printf "\033[36m${project}\033[m:\n" # Outputs in cyan color.
                    git commit --all --cleanup strip --file "$temp_file"
                fi
            fi
        )
    done < <(ls -A1)

    rm -f "$temp_file"
}

# Label: Git Commit and Push (all)
# Description: Commit and push changes for projects in current directory.
gcap() {
    local temp_file=$(mktemp -t git-commit)
    cp "$HOME"/.config/git/commit_message.txt "$temp_file"
    $EDITOR --wait "$temp_file"

    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                # Only process projects that have changes.
                if [[ "$(git status --short)" ]]; then
                    printf "\033[36m${project}\033[m:\n" # Outputs in cyan color.
                    git commit --all --cleanup strip --file "$temp_file" && git push
                fi
            fi
        )
    done < <(ls -A1)

    rm -f "$temp_file"
}

# Label: Git Push Origin Branch
# Description: Pushes current branch to origin and sets upstream tracking.
gpob() {
    git push --set-upstream origin $(_git_branch_name)
}

# Label: Git Push (all)
# Description: Push changes for projects in current directory.
gpa() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                # Only process projects that have changes.
                if [[ "$(git status --short --branch)" == *"[ahead"*"]" ]]; then
                    printf "\033[36m${project}\033[m:\n" # Outputs in cyan color.
                    git push
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Rebase (interactive)
# Description: Rebase commits, interactively.
# Parameters: $1 (optional) - The number of commits or label (i.e. branch/tag) to rebase to.
grbi() {
    local number_pattern="^[0-9]+$"
    local label_pattern="^[0-9a-zA-Z\_-]+$"
    local parent_sha=$(git log --pretty=format:%h -n 1 "$(_git_branch_sha)^" 2>/dev/null || :)
    local value="${1:-$parent_sha}"

    if [[ "$value" =~ $number_pattern ]]; then
        git rebase --keep-empty --interactive "@~${value}"
    elif [[ $(_git_branch_name) == "master" && -z "$(git config remote.origin.url)" ]]; then
        git rebase --keep-empty --interactive --root
    elif [[ "$value" =~ $label_pattern ]]; then
        git rebase --keep-empty --interactive "$value"
    else
        printf "%s\n" "Invalid commit SHA, branch label, or repo has remote: $value."
        return 1
    fi
}

# Label: Git Rebase (quick)
# Description: Rebase commits, quickly. Identical to `grbi` function but skips editor.
# Parameters: $1 (optional) - The commit number or branch to rebase to. Default: upstream or root.
grbq() {
    EDITOR=true grbi "$1"
}

# Label: Git Branch List
# Description: List local and remote branch details.
gbl() {
    local format="%(refname)|%(color:yellow)%(objectname)|%(color:reset)|%(color:blue bold)%(authorname)|%(color:green)|%(committerdate:relative)"
    _git_branch_list "$format" | column -s'|' -t
}

# Label: Git Branch List Owner
# Description: List branches owned by current author or supplied author.
# Parameters: $1 (optional) - The author name.
gblo() {
    local owner="${1:-$(git config user.name)}"
    gbl | ag --nocolor "$owner"
}

# Label: Git Branch List (all)
# Description: List current branch for projects in current directory.
gbla() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                local branch="$(_git_branch_name)"
                printf "\033[36m${project}\033[m: " # Output in cyan color.

                if [[ "$branch" == "master" ]]; then
                    printf "%s\n" "$branch"
                else
                    printf "\033[31m$branch\033[m\n" # Output in red color.
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Branch Create
# Description: Create and switch to branch.
# Parameters: $1 (required) - New branch name.
gbc() {
    local name="$1"

    if [[ "$name" ]]; then
        git switch --create "$name" --track
        printf "%s" "$name" | _copy_and_print
    else
        printf "%s\n" "ERROR: Branch name must be supplied."
        return 1
    fi
}

# Label: Git Branch Facsimile
# Description: Duplicate current branch with new name and switch to it.
# Parameters: $1 (required) - New branch name.
gbf() {
    local new="$1"
    local old="$(_git_branch_name)"

    if [[ "$new" ]]; then
        git switch --create "$new" "$old" --track
        git commit --allow-empty --no-verify --message "----- End of $old work -----"
    else
        printf "%s\n" "ERROR: Branch name must be supplied."
        return 1
    fi
}

# Label: Git Branch Create (all)
# Description: Create and switch to branch for projects in current directory.
# Parameters: $1 (required) - The branch name.
gbca() {
    local branch="$1"

    if [[ -n "$branch" ]]; then
        while read -r project; do
            (
                cd "$project" || exit

                if [[ -d ".git" ]]; then
                    if [[ "$(_git_branch_name)" != "$branch" ]]; then
                        git switch --create "$branch" --track
                        printf "\033[36m${project}\033[m: $branch\n" # Output in cyan and branch in white color.
                    fi
                fi
            )
        done < <(ls -A1)
    else
        printf "%s\n" "ERROR: Branch name must be supplied."
    fi
}

# Label: Git Branch Switch
# Description: Switch between branches.
gbs() {
    if [[ -d ".git" ]]; then
        local branches=()
        local ifs_original=$IFS
        IFS=$'\n'

        branches=($(_git_branch_list_alpha))

        if [[ ${#branches[@]} -gt 1 ]]; then
            printf "\n%s\n" "Select branch to switch to:"

            for ((index = 0; index < ${#branches[*]}; index++)); do
                printf "  %s\n" "$index: ${branches[$index]}"
            done

            printf "  %s\n\n" "q: Quit/Exit."

            read -p "Enter selection: " response
            printf "\n"

            local match="^([0-9]{1,2})$"
            if [[ "$response" =~ $match ]]; then
                local branch="$(printf "${branches[$response]}" | awk '{print $1}')"
                git switch "$branch"
                printf "\n"
            fi
        else
            printf "%s\n" "Sorry, only one branch to switch to and you're on it!"
        fi
    else
        printf "%s\n" "Sorry, no branches to switch to."
    fi

    IFS=$ifs_original
}

# Label: Git Branch Switch (all)
# Description: Switch to given branch for projects in current directory.
# Parameters: $1 (required) - The branch name.
gbsa() {
    local branch="$1"

    if [[ -n "$branch" ]]; then
        while read -r project; do
            (
                cd "$project" || exit

                if [[ -d ".git" ]]; then
                    local current_branch="$(_git_branch_name)"

                    if [[ $(git rev-parse --quiet --verify "$branch") && "$current_branch" != "$branch" ]]; then
                        git switch --quiet "$branch"
                        printf "\033[36m${project}\033[m: $branch\n" # Output in cyan and branch in white color.
                    fi
                fi
            )
        done < <(ls -A1)
    else
        printf "%s\n" "ERROR: Branch name must be supplied."
    fi
}

# Label: Git Branch Number (all)
# Description: Answer number of branches for projects in current directory.
gbna() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                local current_branch="$(_git_branch_name)"
                local number="$(_git_branch_list | ag --invert-match master | wc -l | tr -d ' ')"

                if [[ $number -gt 0 ]]; then
                    # Output project in cyan and number in white color.
                    printf "\033[36m${project}\033[m: $number\n"
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Branch Delete
# Description: Delete branch (select local and/or remote).
gbd() {
    # Only process projects that are Git-enabled.
    if [[ -d ".git" ]]; then
        local branches=()
        local ifs_original=$IFS
        IFS=$'\n'

        branches=($(_git_branch_list_alpha))

        if [[ ${#branches[@]} -gt 1 ]]; then
            printf "\n%s\n" "Select branch to delete:"

            for ((index = 0; index < ${#branches[*]}; index++)); do
                printf "  %s\n" "$index: ${branches[$index]}"
            done

            printf "  %s\n\n" "q: Quit/Exit."

            read -p "Enter selection: " response
            local branch="$(printf "${branches[$response]}" | awk '{print $1}')"
            printf "\n"

            local match="^([0-9]{1,2})$"
            if [[ "$response" =~ $match ]]; then
                gbdl "$branch"
                gbdr "$branch"
            fi
        else
            printf "%s\n" "Sorry, only the master branch exists and it can't be deleted."
        fi
    else
        printf "%s\n" "Sorry, no branches to delete."
    fi

    IFS=$ifs_original
}

# Label: Git Branch Delete (local)
# Description: Delete local branch.
# Parameters: $1 (required) - Branch name.
gbdl() {
    local branch="$1"

    if [[ -n "$(git branch --list "$branch")" ]]; then
        printf "\033[31m" # Red.
        read -p "Delete \"$branch\" local branch (y/n)?: " response
        printf "\033[m" # White.

        if [[ "$response" == 'y' ]]; then
            git branch --delete --force "$branch"
        else
            printf "%s\n" "Local branch deletion aborted."
        fi
    else
        printf "%s\n" "Local branch not found."
    fi
}

# Label: Git Branch Delete (remote)
# Description: Delete remote branch.
# Parameters: $1 (required) - Branch name.
gbdr() {
    local branch="$1"

    if [[ -n "$(git branch --remotes --list origin/"$branch")" ]]; then
        printf "\033[31m" # Red.
        read -p "Delete \"$branch\" remote branch (y/n)?: " response
        printf "\033[m" # White.

        if [[ "$response" == 'y' ]]; then
            git push --delete origin "$branch"
        else
            printf "%s\n" "Remote branch deletion aborted."
        fi
    else
        printf "%s\n" "Remote branch not found."
    fi
}

# Label: Git Branch Delete (merged)
# Description: Delete remote and local merged branches.
gbdm() {
    if [[ $(_git_branch_name) != "master" ]]; then
        printf "%s\n" "ERROR: Whoa, switch to master branch first."
        return 1
    fi

    # Remote
    git branch --remotes --merged |
        ag "origin" |
        ag --invert-match "master" |
        sed 's/origin\///' |
        xargs -n 1 git push --delete origin

    # Local
    git branch --merged | ag --invert-match "\* master" | xargs -n 1 git branch --delete --force
}

# Label: Git Branch Rename
# Description: Rename current branch.
# Parameters: $1 (required) - Branch name.
gbr() {
    local new_branch="$1"
    local old_branch="$(_git_branch_name)"

    git branch --move "$new_branch"

    if [[ -n "$(git branch --remotes --list origin/"$old_branch")" ]]; then
        printf "\033[31m" # Red.
        read -p "Delete \"$old_branch\" remote branch (y/n)?: " response
        printf "\033[m" # White.

        if [[ "$response" == 'y' ]]; then
            git push --delete origin "$old_branch"
        fi
    fi
}

# Label: Git Tag Rebuild
# Description: Rebuild a previous tag. WARNING: Use with caution, especially if previously published.
# Parameters: $1 (required) - Version, $2 (required) - Release notes path, $3 (optional) - Creation date/time. Default: current date/time.
gtagr() {
    local version="$1"
    local path="$2"
    local datetime="${3:-$(date '+%Y-%m-%d %H:%M:%S')}"

    GIT_COMMITTER_DATE="$datetime" git tag --force --sign --file "$path" "$version"
}

# Label: Git Tag Delete
# Description: Delete local and remote tag (if found).
# Parameters: $1 (required) - The tag name.
gtagd() {
    if [[ -z "$1" ]]; then
        printf "%s\n" "ERROR: Tag name must be supplied."
        return 1
    fi

    read -p "Delete '$1' tag from local and remote repositories. Continue (y/n)?: " response

    if [[ "$response" == 'y' ]]; then
        printf "%s " "Local:"
        if [[ -n "$(git tag --list "$1")" ]]; then
            git tag --delete "$1"
        else
            printf "%s\n" "No tag found."
        fi

        printf "%s " "Remote:"
        if [[ $(git config remote.origin.url) && -n "$(git ls-remote --tags origin | ag "$1")" ]]; then
            git push --delete origin "$1"
        else
            printf "%s\n" "No tag found."
        fi
    else
        printf "%s\n" "Tag deletion aborted."
    fi
}

# Label: Git Worktree Add
# Description: Add and switch to new worktree.
# Parameters: $1 (required) - Worktree/branch name, $2 (required) Option.
gwa() {
    local name="$1"
    local option="$2"
    local project_name="$(basename $(pwd))"
    local worktree_path="../$project_name-$name"

    if [[ -z "$name" ]]; then
        printf "%s\n" "ERROR: Worktree name must be supplied."
        return 1
    fi

    if [[ "$option" != "d" && -n $(git branch --list "$name") ]]; then
        printf "%s\n" "ERROR: Invalid worktree, local branch exists."
        return 1
    fi

    case $option in
    'd')
        git worktree add --detach "$worktree_path" HEAD
        ;;
    'r')
        git worktree add -b "$name" "$worktree_path" origin/"$name"
        ;;
    'l')
        git worktree add -b "$name" "$worktree_path" master
        ;;
    *)
        printf "%s\n" "ERROR: Invalid worktree option: Use: (d)etach, (r)emote, or (l)ocal."
        return 1
        ;;
    esac

    printf "%s\n" "Syncing project files..."
    git ls-files --others | rsync --compress --links --files-from - "$(pwd)/" "$worktree_path/"
    cd "$worktree_path" || exit
}

# Label: Git Worktree Delete
# Description: Deletes current Git worktree.
gwd() {
    local project_name="$(basename $(git rev-parse --show-toplevel) | cut -d'-' -f1)"
    local worktree_dir="$(pwd)"
    local branch="$(_git_branch_name)"

    if [[ "$(git status --short)" ]]; then
        printf "%s\n" "ERROR: Git worktree has uncommitted changes."
        return 1
    else
        cd ../$project_name || exit
        read -p "Git worktree: $worktree_dir. Delete (y/n)?: " response

        if [[ "$response" == 'y' ]]; then
            rm -rf "$worktree_dir"
            git worktree prune
            gbdl "$branch"
            git branch --delete --force "$branch"
        fi
    fi
}

# Label: Git Remote Add
# Description: Add and track a remote repository.
# Parameters: $1 (required) - Repository URL, $2 (optional) - Name. Default: upstream
gra() {
    local url="$1"
    local name="${2:-upstream}"

    if [[ -z "$url" ]]; then
        printf "%s\n" "ERROR: Repository URL must be supplied."
        return 1
    fi

    git remote add -t master -f "$name" "$url"
}

# Label: Git Reset Soft
# Description: Resets previous commit (default), resets back to number of commits, or resets to specific commit.
# Parameters: $1 (optional) - The number of commits to reset or a specific commit SHA.
gess() {
    local value="$1"
    local number_pattern="^[0-9]+$"
    local commit_pattern="^[a-f0-9]+$"

    if [[ "$value" =~ $number_pattern ]]; then
        git reset --soft "HEAD~${value}"
    elif [[ "$value" =~ $commit_pattern ]]; then
        git reset --soft "${value}"
    else
        git reset --soft HEAD^
    fi
}

# Label: Git Reset Hard
# Description: Reset to HEAD, destroying all untracked, staged, and unstaged changes. UNRECOVERABLE!
# Parameters: $1 (optional) - The number of commits to reset or a specific commit SHA.
gesh() {
    local value="$1"
    local number_pattern="^[0-9]+$"
    local commit_pattern="^[a-f0-9]+$"

    git clean --force --quiet -d

    if [[ "$value" =~ $number_pattern ]]; then
        git reset --hard "HEAD~${value}"
    elif [[ "$value" =~ $commit_pattern ]]; then
        git reset --hard "${value}"
    else
        git reset --hard HEAD
    fi
}

# Label: Git Reset Hard (all)
# Description: Destroy all untracked, staged, and unstaged changes for all projects in current directory. UNRECOVERABLE!
# Parameters: $1 (optional) - The number of commits to reset or a specific commit SHA.
gesha() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                printf "\n\033[36m${project}\033[m:\n" # Outputs in cyan color.
                grh "$1"
            fi
        )
    done < <(ls -A1)
}

# Label: Git Nuke
# Description: Permanently destroy and erase a file from history. UNRECOVERABLE!
# Parameters: $1 (optional) - The file to destroy.
guke() {
    local file="$1"

    if [[ -z "$file" ]]; then
        printf "%s\n" "ERROR: File to nuke must be supplied."
        return 1
    fi

    printf "\033[31m" # Switch to red font.
    read -p "Permanently delete '$file' from the local repository. Continue (y/n)?: " response
    printf "\033[m" # Switch to white font.

    if [[ "$response" == 'y' ]]; then
        git-filter-repo --force --invert-paths --path "$file"
    else
        printf "%s\n" "Nuke aborted."
    fi
}

# Label: Git Clean (all)
# Description: Clean uncommitted files from all projects in current directory.
gleana() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                # Only process projects that have untracked changes.
                if [[ "$(git status --untracked-files --short)" ]]; then
                    printf "\n\033[36m${project}\033[m:\n" # Outputs in cyan color.
                    git clean -d --force
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: Git Clear
# Description: Clear repository for packaging/shipping purposes.
glear() {
    if [[ ! -d .git ]]; then
        printf "%s\n" "ERROR: Project is not a Git repository."
        return 1
    fi

    read -p "Permanently delete/compact repository files? Continue (y/n)?: " response

    if [[ "$response" == "y" ]]; then
        printf "%s\n\n" "Verifying connectivity and validity of the objects in Git repository..."
        git fsck

        printf "%s\n\n" "Pruning rerere records of older conflicting merges..."
        git rerere gc

        printf "\n%s\n\n" "Aggressively pruning repository..."
        git gc --aggressive --prune=now

        printf "\n%s\n" "Clearing reflog..."
        git reflog expire --expire=now --all

        printf "\n%s\n" "Clearing commit message file..."
        echo >.git/COMMIT_EDITMSG

        printf "\n%s\n" "Clearing sample Git Hooks..."
        rm -rf .git/hooks/*.sample

        printf "\n%s\n" "Deleting Node modules..."
        rm -rf node_modules

        printf "\n%s\n" "Deleting temp directory..."
        rm -rf tmp
    else
        printf "%s\n" "Git clear aborted."
    fi
}

# Label: Git Verify and Clean
# Description: Verify and clean objects for current project.
gvac() {
    printf "%s\n\n" "Verifying connectivity and validity of the objects in Git repository..."
    git fsck

    printf "\n%s\n\n" "Cleaning unnecessary files and optimizing local Git repository..."
    git gc

    printf "%s\n\n" "Pruning rerere records of older conflicting merges..."
    git rerere gc
}

# Label: Git Verify and Clean (all)
# Description: Verify and clean objects for projects in current directory.
gvaca() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                printf "\n\033[36m${project}\033[m:\n" # Outputs in cyan color.
                git fsck && git gc && git rerere gc
            fi
        )
    done < <(ls -A1)
}

# Label: Git Log Line Format
# Description: Print single line log format.
_git_log_line_format() {
    printf "%s" "%C(yellow)%h%C(reset) %G? %C(bold blue)%an%C(reset) %s%C(bold cyan)%d%C(reset) %C(green)%cr.%C(reset)"
}

# Label: Git Log Details Format
# Description: Prints default log format.
_git_log_details_format() {
    printf "%s" "$(_git_log_line_format) %n%n%b%n%N%-%n"
}

# Label: Git Show Details
# Description: Show commit/file change details in a concise format.
# Parameters: $1 (required) - The params to pass to git show.
_git_show_details() {
    git show --stat --pretty=format:"$(_git_log_details_format)" $@
}

# Label: Git Commits Since Last Tag
# Description: Answer commit history since last tag for project.
_git_commits_since_last_tag() {
    if [[ $(git tag) ]]; then
        git log --oneline --reverse --format='%C(yellow)%h%Creset %s' $(git describe --abbrev=0 --tags --always)..HEAD
    else
        git log --oneline --reverse --format='%C(yellow)%h%Creset %s'
    fi
}

# Label: Git Commit Count Since Last Tag
# Description: Answer commit count since last tag for project.
# Parameters: $1 (optional) - The output prefix. Default: null., $2 (optional) - The output suffix. Default: null.
_git_commit_count_since_last_tag() {
    local prefix="$1"
    local suffix="$2"
    local count=$(_git_commits_since_last_tag | wc -l | xargs -n 1)

    if [[ -n $count ]]; then
        # Prefix
        if [[ -n "$prefix" ]]; then
            printf "\033[36m${prefix}\033[m: " # Cyan.
        fi

        # Commit Count
        if [[ $count -ge 30 ]]; then
            printf "\033[31m$count\033[m" # Red.
        elif [[ $count -ge 20 && $count -le 29 ]]; then
            printf "\033[1;31m$count\033[m" # Light red.
        elif [[ $count -ge 10 && $count -le 19 ]]; then
            printf "\033[33m$count\033[m" # Yellow.
        else
            printf "$count" # White.
        fi

        # Suffix
        if [[ -n "$suffix" ]]; then
            printf "$suffix"
        fi
    fi
}

# Label: Git Commit Last
# Description: Answer last commit for current branch.
_git_commit_last() {
    git log --pretty=format:%h -1
}

# Label: Git Last Tag Info
# Description: Answer last tag for project (including commits added since tag was created).
_git_last_tag_info() {
    printf "%s\n" "$(git describe --tags --always) ($(_git_commit_count_since_last_tag) commits since)"
}

# Label: Git File Commits
# Description: Print file commit history (with optional diff support).
# Parameters: $1 (required) - The file path.
_git_file_commits() {
    local commits=("${!1}")
    local file="$2"
    local commit_total=${#commits[@]}
    local option_padding=${#commit_total}
    local counter=1

    _git_commit_options "${commits[*]}"

    read -r -p "Enter selection: " response
    if [[ "$response" == 'q' ]]; then
        return
    fi

    printf "\n"
    local selected_commit=${commits[$((response - 1))]}
    _git_show_details "$selected_commit"

    printf "\n"
    read -p "View diff (y = yes, n = no)? " response
    if [[ "$response" == 'y' ]]; then
        gdt "$selected_commit"^! -- "$file"
    fi
}

# Label: Git Commit Options
# Description: Print options for interacting with Git commits.
# Parameters: $1 (required) - Commit array, $2 (optional) - Options label. Default: "Commits".
_git_commit_options() {
    local commits=("${1}")
    local label="${2:-Commits}"
    local commit_total=${#commits[@]}
    local option_padding=${#commit_total}
    local counter=1

    if [[ ${#commits[@]} == 0 ]]; then
        printf "%s\n" "No commits found."
        return 0
    fi

    printf "%s:\n\n" "$label"

    for commit in ${commits[@]}; do
        local option="$(printf "%${option_padding}s" $counter)"
        printf "%s\n" "$option: $(git log --color --pretty=format:"$(_git_log_line_format)" -n1 "$commit")"
        counter=$((counter + 1))
    done

    option_padding=$((option_padding + 1))
    printf "%${option_padding}s %s\n\n" "q:" "Quit/Exit."
}

# Label: Git Branch Name
# Description: Print Git branch name.
_git_branch_name() {
    git branch --show-current | tr -d '\n'
}

# Label: Git Branch SHAs
# Description: Answer branch commit SHAs regardless of branch nesting.
_git_branch_shas() {
    local ifs_original=$IFS
    IFS=$'\n'

    local log_format="%h%d"
    local current_commit=($(git log --pretty=format:$log_format) -1)
    local commits=($(git log --pretty=format:$log_format))
    local parent_sha="$(_git_commit_last)"
    local current_pattern=".*\(HEAD.+\)*"
    local parent_pattern=".*\(.+\)*"
    local origin_pattern=".*\(origin\/$(_git_branch_name)\)$"
    local master_pattern=".*\(.+master(\,|\))*"

    if [[ ! "$current_commit" =~ $master_pattern ]]; then
        for entry in ${commits[@]}; do
            local entry_sha="${entry%% *}"

            if [[ ! "$entry" =~ $current_pattern && ! "$entry" =~ $origin_pattern ]]; then
                if [[ "$entry" =~ $master_pattern ]]; then
                    parent_sha="$entry_sha"
                    break
                elif [[ "$entry" =~ $parent_pattern ]]; then
                    parent_sha="$entry_sha"
                    break
                fi
            fi
        done
    fi

    git log --pretty=format:%h "$parent_sha..$(_git_commit_last)"
    IFS=$ifs_original
}

# Label: Git Branch SHA
# Description: Answer SHA from which the branch was created.
_git_branch_sha() {
    local shas=($(_git_branch_shas))

    if [[ ${#shas[@]} != 0 ]]; then
        printf "%s" "${shas[-1]}"
    fi
}

# Label: Git Branch List (alphabetical)
# Description: List branches (local/remote) alphabetically.
# Parameters: $1 (optional) - The output format.
_git_branch_list_alpha() {
    _git_branch_list "$1" | sort
}

# Label: Git Branch List
# Description: List branches (local/remote) including author and relative time.
# Parameters: $1 (optional) - The output format.
_git_branch_list() {
    local format=${1:-"%(refname) %(color:blue bold)%(authorname) %(color:green)(%(authordate:relative))"}

    git for-each-ref --sort="authordate:iso8601" \
        --sort="authorname" \
        --color \
        --format="$format" refs/heads refs/remotes/origin |
        sed '/HEAD/d' |
        sed 's/refs\/heads\///g' |
        sed 's/refs\/remotes\/origin\///g' |
        uniq
}

# Label: Git Stash Count
# Description: Answer total stash count for current project.
_git_stash_count() {
    git stash list | wc -l | xargs -n 1
}

# Label: Git Stash
# Description: Enhance default git stash behavior by prompting for input (multiple) or using last stash (single).
# Parameters: $1 (required) - The Git stash command to execute, $2 (required) - The prompt label (for multiple stashes).
_process_git_stash() {
    local stash_command="$1"
    local stash_index=0
    local prompt_label="$2"
    local ifs_original=$IFS
    IFS=$'\n'

    # Store existing stashes (if any) as an array. See public, "gashl" for details.
    stashes=($(gashl))

    if [[ ${#stashes[@]} == 0 ]]; then
        printf "%s\n" "Git stash is empty. Nothing to do."
        return 0
    fi

    # Ask which stash to show when multiple stashes are detected, otherwise show the existing stash.
    if [[ ${#stashes[@]} -gt 1 ]]; then
        printf "%s\n" "$prompt_label:"
        for ((index = 0; index < ${#stashes[*]}; index++)); do
            printf "  %s\n" "$index: ${stashes[$index]}"
        done
        printf "  %s\n\n" "q: Quit/Exit."

        read -p "Enter selection: " response

        local match="^[0-9]{1}$"
        if [[ "$response" =~ $match ]]; then
            printf "\n"
            stash_index="$response"
        else
            return 0
        fi
    fi

    IFS=$ifs_original
    eval "$stash_command stash@{$stash_index}"
}

#---------------------------------------#
# Section: [GitHub](https://github.com) #
#---------------------------------------#

# Label: GitHub
# Description: View GitHub details for current project.
# Parameters: $1 (optional) - The option selection, $2 (optional) - The option input.
gh() {
    if [[ -d ".git" ]]; then
        while true; do
            if [[ $# == 0 ]]; then
                printf "\n%s\n" "Usage: gh OPTION"
                printf "\n%s\n" "GitHub Options (default browser):"
                printf "%s\n" "  o: Open repository."
                printf "%s\n" "  i: Open repository issues."
                printf "%s\n" "  c: Open repository commits. Options:"
                printf "%s\n" "     HASH: Open commit."
                printf "%s\n" "  f: Copy repository file URL."
                printf "%s\n" "  b: Open repository branches. Options:"
                printf "%s\n" "     c: Open current branch."
                printf "%s\n" "     d: Open diff for current branch."
                printf "%s\n" "     r: Open pull request for current branch."
                printf "%s\n" "  t: Open repository tags."
                printf "%s\n" "  r: Open repository pull requests."
                printf "%s\n" "     NUMBER: Open pull request."
                printf "%s\n" "     l: List pull requests."
                printf "%s\n" "  w: Open repository wiki."
                printf "%s\n" "  p: Open repository pulse."
                printf "%s\n" "  g: Open repository graphs."
                printf "%s\n" "  s: Open repository settings."
                printf "%s\n" "  u: Print and copy repository URL. Options:"
                printf "%s\n" "     HASH: Print and copy commit URL."
                printf "%s\n" "     l: Print and copy last commit URL."
                printf "%s\n\n" "  q: Quit/Exit."
                read -p "Enter selection: " response
                printf "\n"
                _process_gh_option "$response" "$2"
            else
                _process_gh_option "$1" "$2" "$3"
            fi
            break
        done
    else
        printf "%s\n" "ERROR: Not a Git repository!"
        return 1
    fi
}

# Label: GitHub Pull Request (all)
# Description: Open pull requests for all projects in current directory (non-master branches only).
ghpra() {
    while read -r project; do
        (
            cd "$project" || exit

            if [[ -d ".git" ]]; then
                if [[ "$(_git_branch_name)" != "master" ]]; then
                    gh b r # a.k.a. GitHub Branch Pull Request
                fi
            fi
        )
    done < <(ls -A1)
}

# Label: GitHub URL
# Description: Answer GitHub URL for current project.
_gh_url() {
    local remote="$(git remote -v | ag github.com | ag fetch | head -1 | cut -f2 | cut -d' ' -f1)"
    local match="^git@.*"

    if [[ "$remote" =~ $match ]]; then
        printf "$remote" | sed -e 's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//'
    else
        printf "$remote"
    fi
}

# Label: GitHub Pull Request List
# Description: List pull requests (local/remote) including subject, author, and relative time.
# Parameters: $1 (optional) - The output format.
_gh_pr_list() {
    local format=${1:-"%(refname) %(color:yellow)%(refname)%(color:reset) %(subject) %(color:blue bold)%(authorname) %(color:green)(%(committerdate:relative))"}

    git for-each-ref --color --format="$format" refs/remotes/pull_requests |
        sed 's/refs\/remotes\/pull_requests\///g' |
        sort --numeric-sort |
        cut -d' ' -f2-
}

# Label: Process GitHub Commit Option
# Description: Process GitHub commit option for remote repository viewing.
# Parameters: $1 (optional) - The commit hash.
_process_gh_commit_option() {
    local commit="$1"

    if [[ "$commit" ]]; then
        open "$(_gh_url)/commit/$commit"
    else
        open "$(_gh_url)/commits"
    fi
}

# Label: Process GitHub File Option
# Description: Process GitHub file option for remote repository viewing.
# Parameters: $1 (required) - The local (relative) file path, $2 (optional) - The line numbers.
_process_gh_file_option() {
    local path="$1"
    local lines="$2"
    local start_index=$(pwd | wc -c)
    local end_index=$(printf "$path" | wc -c)
    local url="$(_gh_url)/blob/$(_git_branch_name)/${path:$start_index:$end_index}"

    if [[ -n "$lines" ]]; then
        url="$url#$lines"
    fi

    printf "$url" | _copy_and_print
}

# Label: Process GitHub Branch Option
# Description: Process GitHub branch option for remote repository viewing.
# Parameters: $1 (optional) - The option.
_process_gh_branch_option() {
    case $1 in
    'c')
        open "$(_gh_url)/tree/$(_git_branch_name)"
        ;;
    'd')
        open "$(_gh_url)/compare/$(_git_branch_name)"
        ;;
    'r')
        open "$(_gh_url)/compare/$(_git_branch_name)?expand=1"
        ;;
    *)
        open "$(_gh_url)/branches"
        ;;
    esac
}

# Label: Process GitHub Pull Request Option
# Description: Process GitHub pull request option for remote repository viewing.
# Parameters: $1 (optional) - The option.
_process_gh_pull_request_option() {
    local option="$1"
    local number_match="^[0-9]+$"

    if [[ "$option" =~ $number_match ]]; then
        open "$(_gh_url)/pull/$option"
    elif [[ "$option" == 'l' ]]; then
        _gh_pr_list
    else
        open "$(_gh_url)/pulls"
    fi
}

# Label: Process GitHub URL Option
# Description: Processes GitHub URL option for remote repository viewing.
# Parameters: $1 (optional) - The commit/option.
_process_gh_url_option() {
    local commit="$1"
    local commit_match="^([0-9a-f]{40}|[0-9a-f]{7})$"

    if [[ "$commit" =~ $commit_match ]]; then
        printf "$(_gh_url)/commit/$commit" | _copy_and_print
    elif [[ "$commit" == 'l' ]]; then
        printf "$(_gh_url)/commit/$(_git_commit_last)" | _copy_and_print
    else
        _gh_url | _copy_and_print
    fi
}

# Label: Process GitHub Option
# Description: Processes GitHub option for remote repository viewing.
# Parameters: $1 (optional) - The first option, $2 (optional) - The second option.
_process_gh_option() {
    case $1 in
    'o')
        open $(_gh_url)
        ;;
    'i')
        open "$(_gh_url)/issues"
        ;;
    'c')
        _process_gh_commit_option "$2"
        ;;
    'f')
        _process_gh_file_option "$2" "$3"
        ;;
    'b')
        _process_gh_branch_option "$2"
        ;;
    't')
        open "$(_gh_url)/tags"
        ;;
    'r')
        _process_gh_pull_request_option "$2"
        ;;
    'w')
        open "$(_gh_url)/wiki"
        ;;
    'p')
        open "$(_gh_url)/pulse"
        ;;
    'g')
        open "$(_gh_url)/graphs"
        ;;
    's')
        open "$(_gh_url)/settings"
        ;;
    'u')
        _process_gh_url_option "$2"
        ;;
    'q') ;;
    *)
        printf "%s\n" "ERROR: Invalid option."
        ;;
    esac
}

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

. $HOME/.config/zsh/zensh/emoji-log.zsh
