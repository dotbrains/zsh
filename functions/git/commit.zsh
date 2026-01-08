#!/usr/bin/env zsh
# Git commit-related functions

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

