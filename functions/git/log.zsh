#!/usr/bin/env zsh
# Git log and history functions

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

