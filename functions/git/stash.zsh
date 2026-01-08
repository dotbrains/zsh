#!/usr/bin/env zsh
# Git stash-related functions

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

