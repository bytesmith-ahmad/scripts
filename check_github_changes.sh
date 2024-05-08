#!/bin/bash

# Define colors for different categories
task_color="\033[91m"       # Yellow for tasks
password_color="\033[34m"   # Blue for passwords
archive_color="\033[35m"    # Magenta for archives
finance_color="\033[32m"    # Green for finances
home_color="\033[38;5;208m" # Orange for home
journal_color="\033[96m"    # Cyan for journal
reset_color="\033[0m"

# Synchronize home
echo -en "${home_color}Home: ${reset_color}"

# Define your GitHub repository URL
github_repo="$github/home"

# Check for changes in the remote repository
git remote update > /dev/null 2>&1

# Check if there are any changes
if git status -uno | grep -q 'Your branch is behind'; then
    # Changes found, prompt the user
    read -p "Found changes in the remote repository. Do you want to pull? (Y/N): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        # User confirmed, pull changes
        git pull "$github_repo"
                
        read -n1 -p "Press key to reset..."
        reset
    else
        echo "Changes not pulled."
    fi
else
    echo "No changes found in the remote repository."
fi

# Synchronize password-store
echo -en "${password_color}Passwords: ${reset_color}"
pass git pull

# Synchronize archives
echo -en "${archive_color}Archives: ${reset_color}"
git -C archives pull

# Synchronize journal
echo -en "${journal_color}Journal: ${reset_color}"
git -C journal pull

# Synchronize bills
echo -en "${finance_color}Bills: ${reset_color}"
git -C .bills pull

# Synchronize tasks
echo -en "${task_color}Task: ${reset_color}"
git -C .task pull
