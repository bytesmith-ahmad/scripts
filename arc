#!/bin/bash

# Function to display usage instructions
function display_usage() {
    echo "Usage: $0 <directory> [as <new_file_path>]"
    echo "Example: $0 /path/to/directory"
    echo "         $0 /path/to/directory as /new/file/path"
}

# Check if no arguments are provided
if [ "$#" -eq 0 ]; then
    display_usage
    exit 1
fi

# Check if only one argument provided (Case 2)
if [ "$#" -eq 1 ]; then
    if [ -d "$1" ]; then
        tar -czvf "$1.arc" -C "$1" .
        exit $?
    else
        echo "Error: Not a directory."
        display_usage
        exit 1
    fi
fi

# Check if 'as' keyword is provided (Case 3)
if [ "$#" -eq 3 ] && [ "$2" = "as" ]; then
    if [ -d "$1" ]; then
        tar -czvf "$3.arc" -C "$1" .
        exit $?
    else
        echo "Error: Not a directory."
        display_usage
        exit 1
    fi
fi

# Final case: Output usage and exit with error
echo "Error: Invalid arguments."
display_usage
exit 1
