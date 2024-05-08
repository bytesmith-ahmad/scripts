#!/bin/bash

# This is a `task` decorator.

target="$HOME/tasks"

# Define an associative array to store option descriptions
declare -A option_descriptions=(
    [" "]="Display at most 10 tasks"
    ["courses"]="Shows you courses"
    ["debug"]="Develop this script"
    ["help"]="Display a help message"
    ["open"]="cd to task's directory [Not implemented]"
    # ["rv"]=
    ["sync"]="Synchronize with Github"
    ["*"]="Any other patterns executes as task *"
)

# from config
# alias add='source task-add' TODO
# alias mod='source task-mod' TODO
# alias open='source task-open' TODO

main() {
    #warn "This is a warning"

    if [ $# -eq 0 ]; then no_arg_fn; fi

    case "$1" in
        courses) show_courses ;;
        debug) open_this_file ;;
        help | --help) help ;;
        open) warn "Not implemented." ; exit 1 ;;
        sync) synchronize ;;
        *) execute_and_push "$@" ;;
    esac

    # Process should not reach this point, if it does, maybe forgot exit
    echo -e "\e[31mERROR\e[0m" >&2
    exit 1
}

# Now add functions here in alphabetical order **********************************************

show_courses() {
    t next +course
}

execute_and_push() {
    task "$@"
    case "$1" in
        ad*|mod*|edit|done|undo|del*) push_to_github "$@" ;;
        start|stop|done) no_arg_fn ;;
        *) exit "$?";;
    esac
}

no_arg_fn() {
    out=$(task active 2>&1)
    if [[ "$out" == "No matches." ]]; then
        warn "No active tasks currently"
        task limit:10
        exit "$?"
    else
        task active
        exit "$?"
    fi
}

# Help function to display usage information and option descriptions
help() {
    # ANSI color codes for colors without using \e[33m and \e[31m
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    echo "Usage: $(basename "$0") [OPTIONS]"
    echo -e "\e[96mAdditional functonality to TaskWarrior's task\e[0m"
    echo -e "For greater help, do task help"
    for option in "${!option_descriptions[@]}"; do
        printf "  ${GREEN}%-12s${NC} %s\n" "$option" "${option_descriptions[$option]}"
    done
    exit 0
}

open_this_file() {
    micro $0
    exit "$?"
}

push_to_github() {
    git -C $target add .
    git -C $target commit -m "'$*'" > /dev/null
    git -C $target push
    exit "$?"
}

synchronize() {
    output=$(git -C "$target" pull)
    # Check if the output contains "Already up to date."
    if [[ "$output" == "Already up to date." ]]; then
        # warn "Already up to date. Pushing changes..."
        push_to_github "Sent from $NAME"
    else
        echo "Changes found. Was pull successful\?"
    fi
}

warn() { echo -e "\e[33m$@\e[0m"; }

# pass comands to TaskWarrior
main "$@"
