#!/bin/bash

# Define colors for different categories
task_color="\033[91m"       # Yellow for tasks
password_color="\033[34m"   # Blue for passwords
archive_color="\033[35m"    # Magenta for archives
finance_color="\033[32m"    # Green for finances
home_color="\033[38;5;208m" # Orange for home
journal_color="\033[96m"    # Cyan for journal
reset_color="\033[0m"

# Synchronize rc-files
echo -en "Configuration: "
git -C "$HOME/rc-files" pull

# Synchronize password-store
echo -en "${password_color}Passwords: ${reset_color}"
pass git pull

# Synchronize archives
echo -en "${archive_color}Archives: ${reset_color}"
git -C "$HOME/archives" pull

# Synchronize journal
echo -en "${journal_color}Journal: ${reset_color}"
git -C "$HOME/journal" pull

# Synchronize bills
echo -en "${finance_color}Bills: ${reset_color}"
git -C "$HOME/bills" pull

# Synchronize tasks
echo -en "${task_color}Task: ${reset_color}"
git -C tasks pull

# Synchronize bin
echo -en "Bin: "
git -C "$HOME/bin" pull
