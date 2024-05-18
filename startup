#!/bin/bash

# sequence of startup
main() {
    # warning "example warning"
    update_home
    echo ""
    show_date
    echo ""
    show_RV
    echo ""
    task_summary
}

warning(){
    echo -e "\e[33m$@\e[0m"
}

update_home() {
    # Check for github changes and pull them
    ~/bin/check_github_changes.sh
}

show_date() {
    # Display date and time with decoration
    print_decoration "*" 28
    print_color "$(date)" "1;36"
    print_decoration "*" 28
}

show_RV() {
    echo -ne "\e[7;97mAPPOINTMENTS\e[27;39m"
    task all +appointment
}

# Display tasks from taskwarrior
task_summary() {
    echo -ne "\e[7;97mTASKS\e[27;39m"
    # task summary
    task context none >/dev/null 2>&1
    task limit:5
}

# Function to print decorations
print_decoration() {
    local decoration="$1"
    local length="$2"
    printf "%*s\n" "$length" "" | tr " " "$decoration"
}

# Function to print text with color
print_color() {
    local text="$1"
    local color="$2"
    printf "\033[${color}m%s\033[0m\n" "$text"
}

main
