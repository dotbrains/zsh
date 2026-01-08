#!/usr/bin/env zsh
# Git utility and internal functions


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

