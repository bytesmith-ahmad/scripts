#!bin/bash

# warnings
echo -e "\e[33m[config] Consider splitting variables and aliases\e[0m"

# BASH SETTINGS

# VARIABLES ****************************************************************************************

# Path to my scripts
export PATH="$HOME/bin:$PATH"

# Defaults
export VISUAL="code --wait"
export EDITOR="micro"

# Prompt string (PS to make PS1 dynamic)

PS="\[\e[5;92m\]\$(date +'%H:%M')\[\e[0m\] \[\033[01;34m\]\w\[\033[00m\] \[\e[5m\]⚡\[\e[0m\]"

# new version, move to file *****************************************
export PROMPT_COMMAND=__prompt_command
# Function to check if the current branch is ahead of the remote branch
function __prompt_command() {
    # This needs to be first
    local EXIT="$?"

    # Definitions
    local default_color="\[\e[0m\]"  # Reset color
    local warning_color="\[\e[33m\]" # Yellow color
    local error_color="\[\e[31m\]"   # Red color
    local default_symbol=''          # 
    local up_to_date_symbol="♡"      #
    local not_added_symbol="🔶"      # Symbol for case 
    local not_committed_symbol="🔷"  # Symbol for case 
    local ahead_symbol="🔺"          # Symbol for case 
    local behind_symbol="🔻"         # Symbol for case 

    # Default values
    local SYMBOL=""
    local COLOR="\[\e[0m\]"
    PS1=""

    # Check git status
    local git_status=$(git status 2>&1)
    
    if [[ $git_status == *"not a git repository"* ]]; then
        SYMBOL=$default_symbol
        COLOR=$default_color
    elif [[ $git_status == *"Untracked files:"* ]]; then
        SYMBOL=$not_added_symbol
        COLOR=$warning_color
    elif [[ $git_status == *"Changes not staged for commit"* ]]; then
        SYMBOL=$not_added_symbol
        COLOR=$warning_color
    elif [[ $git_status == *"Changes to be committed"* ]]; then
        SYMBOL=$not_committed_symbol
        COLOR=$warning_color
    elif [[ $git_status == *"Your branch is ahead"* ]]; then
        SYMBOL=$ahead_symbol
        COLOR=$warning_color
    elif [[ $git_status == *"Your branch is behind"* ]]; then
        SYMBOL=$behind_symbol
        COLOR=$warning_color
    elif [[ $git_status == *"Your branch is up to date"* ]]; then
        SYMBOL=$up_to_date_symbol
        COLOR=$default_color
    fi

    # Notify error, ovverrides warning
    if [ $EXIT != 0 ]; then
        COLOR=$error_color
    fi
    
    PS1="${SYMBOL} \[\e[5;92m\]\$(date +'%H:%M')\[\e[0m\] \[\033[01;34m\]\w\[\033[00m\] ${COLOR}\[\e[5m\]⚡\[\e[0m\]"

    # single integral ∫
    # Check if git status output is not empty
    white="\e[0;37m"
    _0="\e[0m"
    if [[ -n $(git status -s 2>/dev/null) ]]; then
        echo -e "${white}⌠ Δ$_0"
        # Store the total number of lines in the output
        total_lines=$(git -c color.status=always status -s | wc -l)
        # Iterate over each line of the output
        line_count=0
        while IFS= read -r line; do
            # Increment line count
            ((line_count++))
            # Prepend a character to the beginning of each line
            if ((line_count < total_lines)); then
                printf "${white}|$_0$line\n"
            else
                printf "${white}⌡$_0$line\n"
            fi
        done <<< "$(git -c color.status=always status -s)"
    fi
}

# keeping this simpler version in case the other breaks
# if [[ -n $(git status -s) ]]; then
    # echo ⌠
    # echo -n ⌡
    # git status -s
    # echo "---"
# fi

# Web links
export github="https://github.com/bytesmith-ahmad"

#TaskWarrior
export wksp="$HOME/workspace"
export LIM=10    # limits the number of tasks shown

# COMMANDS ******************************************************************************************

# Config files

alias config="$EDITOR ~/bin/bashconfig.sh"      # extension of ~/.bashrc
alias taskconfig="$EDITOR ~/bin/taskconfig.sh"  # extension of ~/.taskrc

# File handling

alias md="glow"
alias E="$EDITOR"
alias list='tar -tzvf'
alias ..='cd ..'
#alias sql='sqlite3'
alias bat='batcat'
alias view='wslview'          # opens any document
alias viewdb='sqlitebrowser'  # opens .db files
alias peek="tree -L 1"        # shows surface level content of dirs
alias note="notepad.exe"      # open with note

# TaskWarrior MOVED TO SCRIPTS

alias courses='t courses'
alias r-v='task all +appointment'
alias tasks='task limit:10'
alias add='source task-add'
alias mod='source task-mod'
alias del='source task-del'
alias start='source task-start'
alias open='source task-open'
alias stop='source task-stop'
alias undo='source task-undo'
alias done='source task-done'
alias edit='task edit'
alias errands='source errands'
alias switch='source switch_task_context.sh'

# Web

alias chrome="/mnt/c/'Program Files'/Google/Chrome/Application/chrome.exe"
alias cgpt='chrome https://chat.openai.com/c/cc6e1725-5fee-454d-a15f-9477655cbc29/ 2>/dev/null &'

# Utilities

alias j='journal'
alias sc='sc-im'
alias stats='status'
alias c='xclip -selection clipboard'
alias calc='bc -ql'
# alias yq="yq '.comments=\"\"'"

# Common typos
alias gti='git'
