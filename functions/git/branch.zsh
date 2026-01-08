#!/usr/bin/env zsh
# Git branch-related functions

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

