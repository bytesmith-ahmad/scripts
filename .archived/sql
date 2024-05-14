#!/bin/bash

# Check if a database file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <database>"
    exit 1
fi

# Set the database connection
db="$1"

# Function to display tables and prompt user for input
function prompt_user() {
    # Display tables in the database
    echo -e "\033[36mTables in $db:\033[0m"
    sqlite3 -batch "$db" ".tables"
    echo -e "\033[36m-----------\033[0m"
    echo ""

    # Enter loop to prompt user for SQL queries
    while true; do
        # Temporarily change the prompt string
        PS3="sql> "
        
        # Prompt user for input
        echo -en "\033[1;4;38;5;33msql\033[0m"
        read -rp "> " query || break
        
        # Exit loop if user types 'exit'
        if [ "$query" == "exit" ]; then
            break
        fi
        
        # Execute the SQL query using SQLite3
        sqlite3 -batch "$db" ".mode json" "$query" | jtbl 2> /dev/null
    done
}

# Start the prompt loop
prompt_user
