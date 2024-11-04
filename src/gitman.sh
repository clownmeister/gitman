#!/bin/bash

# Syncs git branches
function gitSync() {
    # Get the number of local branches
    BRANCH_COUNT=$(git branch | wc -l)

    # Check if there are more than XX branches and prompt for confirmation
    if [ "$BRANCH_COUNT" -gt 10 ]; then
        read -p "You have $BRANCH_COUNT local branches. Are you sure you want to sync all? (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            echo -e "\e[33mSyncing canceled.\e[0m"
            return
        fi
    fi

    CURRENT_BRANCH=$(git branch --show-current)
    # Syncing current branch
    echo -e "\n\e[92mSyncing current branch $CURRENT_BRANCH\e[0m"
    git fetch --all
    git pull

    # Filter branches with an upstream and check if the upstream exists on the remote
    git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads/ | awk '$2 != "" {print $1}' | grep -v "$CURRENT_BRANCH" | while read branch; do
        UPSTREAM=$(git rev-parse --symbolic-full-name $branch@{u} 2>/dev/null)

        # Check if the upstream branch exists on the remote
        if git ls-remote --exit-code --heads origin "$branch" > /dev/null; then
            echo -e "\n\e[92mSyncing branch $branch with $UPSTREAM\e[0m"
            git checkout $branch
            git pull origin $branch || echo -e "\e[91mFailed to pull $branch, upstream might be gone.\e[0m"
        else
            echo -e "\n\e[33mSkipping $branch: upstream does not exist on the remote.\e[0m"
        fi
    done

    git checkout $CURRENT_BRANCH
    echo -e "\n\e[92mSynced all branches with valid upstreams!\n"
}

# Clears all local branches except default branch
function gitClear() {
    # Fetch all remote branches to ensure we have up-to-date information
    git fetch --all

    # Determine the default branch
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

    # Switch to the default branch
    if git checkout "$DEFAULT_BRANCH"; then
        echo -e "\e[92mSwitched to default branch $DEFAULT_BRANCH.\e[0m"
    else
        echo -e "\e[91mFailed to switch to default branch. Please ensure it exists on the remote.\e[0m"
        return
    fi

    # Loop through all local branches except  default branch
    for branch in $(git branch | grep -v "$DEFAULT_BRANCH"); do
        # Check if the branch has an upstream
        UPSTREAM=$(git rev-parse --symbolic-full-name $branch@{u} 2>/dev/null)

        if [ -z "$UPSTREAM" ]; then
            # No upstream, delete branch without checking
            echo -e "\e[92mDeleting branch $branch (no upstream)\e[0m"
            git branch -D $branch
        else
            # Compare branch to its upstream using correct diff syntax
            if [ -z "$(git diff $branch..$UPSTREAM)" ]; then
                echo -e "\e[92mDeleting branch $branch (no changes compared to upstream $UPSTREAM)\e[0m"
                git branch -D $branch
            else
                echo -e "\e[33mSkipping branch $branch (has changes compared to upstream $UPSTREAM)\e[0m"
            fi
        fi
    done

    echo -e "\n\e[92mCleared all branches without changes or without valid upstream!\n"
}

# Main command dispatcher
case "$1" in
    sync)
        gitSync
        ;;
    clear)
        gitClear
        ;;
    *)
        echo -e "\e[91mUsage: gitman {sync|clear}\e[0m"
        exit 1
        ;;
esac