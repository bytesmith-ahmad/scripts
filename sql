#!/bin/bash

# SQLite3 wrapper script for ease of manipulation inspired by TaskWarrior

warnings() {
	warn "TODO width control"
    warn "add usage case for each function"
    warn "documentation incomplete"
}

# CONFIG ***************************************************************************************
	# toggle debugging info
		DEBUG=1
	# home location of metadata
		home="$HOME/.sql"
	# default values
		DB="$home/unnamed.db"
		MODE="column"
	# prepared queries
        # print feedback on update
		count_changes_pragma='PRAGMA count_changes = true'
        # Get schema version
		schema_version_pragma='PRAGMA schema_version'
		# Fetch version
		sqite_version_query="SELECT 'SQLite version ' || sqlite_version() AS ''" # mode=list
		# Count tables and views
		table_count_query="SELECT count(name) || ' tables found.' AS '' FROM sqlite_master WHERE type='table' OR type='view'" # mode=list
		# List tables
		table_list_query="SELECT name AS 'Tables' FROM sqlite_schema WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' ORDER BY 1"
		# ...

# Define an associative array to store option descriptions
# TODO make function for this
declare -A option_descriptions=(
    [" "]="What happens if no arg given?"
    ["help"]="Display a help message"
    ["debug"]="Opens this script with \$EDITOR"
    ["connect"]="Connect to a database"
    ["tables"]="List tables"
	["switch"]="Switches focus on a table"
	["get"]="Get connection for example"
    ["set"]="Set target table or database"
    ["run | execute"]="Execute a command"
    ["gui"]="Opens sqlitebrowser"
    ["add | insert"]="Insert data into a table"
    ["mod | update"]="Update data in a table"
    ["del | delete"]="Delete data from a table"
    ["undo"]="Undo last operation"
    ["sum"]="Sum columns in a table"
    ["show"]="Show configurations"
    ["-i"]="Launch in interactive mode"
    ["--backup"]="Backup operation (not implemented)"
    ["--dump"]="Dump operation (not implemented)"
    ["--mode"]="Change mode (not implemented)"
    ["--read"]="Read operation (not implemented)"
    ["--width"]="Set new width (not implemented)"
    ["--alter"]="Alter table (not implemented)"
    ["--attach"]="Attach database (not implemented)"
    ["--rollback"]="Rollback operation (not implemented)"
    ["--save"]="Savepoint operation (not implemented)"
    ["*"]="Default function"
)

main() {
    if [ $# -eq 0 ]; then default_function; fi

    case "$1" in
        -[D]  | debug ) debug_this_script ;;
        -[h]  | help  ) shift ; show_help "@" ;;
        -[l]  | tables | ls   ) shift ; list_tables         ;; #TODO
        -[c]  | connect| con* ) shift ; connect_db "$@"     ;;
        -[s]  | select | sel* ) shift ; select_table "$@"   ;;
        -[ia] | insert | add* ) shift ; insert_sql "$@"     ;; #TODO
        -[m]  | update | mod* ) shift ; update_sql "$@"     ;; #TODO
        -[d]  | delete | del* ) shift ; delete_sql "$@"     ;; #TODO
        -[er] | execute| run* ) shift ; execute_sql "$@"    ;; #TODO
        -[z]  | undo          ) shift ; undo_sql            ;; #TODO
        -[g]  | gui           ) shift ; open_sqliteGUI "$@" ;; #TODO
        set   ) shift ; _set "$@"              ;; # set target <table-name> OR set db <dbname> OR set
		get   ) shift ; _get "$@"              ;; # get attribute
        stat* ) shift ; _get "all"             ;; # get all attributes
        aggr* ) shift ; list_aggregate_fn "$@" ;;
        sum   ) shift ; sum_columns "$@"       ;; #TODO
        show  ) shift ; show_configs "$@"      ;; #TODO 
        --backup) warn "---backing up---"      ;; #TODO
        --dump  ) warn "---dumping---"         ;; #TODO
        --mode  ) warn "---changing mode---"   ;; #TODO
        --read  ) warn "---read---"            ;; #TODO
        --widt* ) warn "---new width: $2---"   ;; #TODO
        --alte* ) warn "---altering table---"  ;; #TODO
        --atta* ) warn "---attaching db---"    ;; #TODO
        --roll* ) warn "---rolling back---"    ;; #TODO
        --save* ) warn "---savepoint---"       ;; #TODO
        *) unknown_arg_interpreter "$@" ;;
    esac

    # Process should not reach this point, if it does, maybe forgot exit
    echo -e "\e[31mERROR\e[0m" >&2
    exit 1
}

# Now add functions here in alphabetical order **********************************************

connect_db() {
    # Case 1: $ sql connect
        # No connection. > Connect? [y/n]
            # y > fzf > msg > exit
            # n > exit
        # Yes connection > Connected to $(cat ~/.sql/connection). Found <#> tables. <None|<selection>> selected.
            # No tables  > create one?
                # y > launch gui > exit
                # n > exit
            # Yes tables
                # Not selected > select table?
                    # y > launch_menu
                    # n > exit
                # Selected > exit
    # Case 2: $ sql connect <path>
        # > Connect to <path>?
            # no > exit
            # yes > attempt connection > handle extra cases...
    if [ $# -eq 0 ]; then
        is_connected=$(test_connection)
        debug "is_connected = $is_connected"
        if [[ is_connected -eq 0 ]]
            then connect_dialog=1
            else find_tables=1
        fi
    else
		warn "unchecked db, proceed at your own risk"
        db="$1"
    fi

    if [[ connect_dialog -eq 1 ]]; then
        echo "you have reached the connect  dialaog. Conenct? [y/n] "
        warn "assuming yes..."
        warn "launching fuzzy search, please select database..."
        db=$(find "$HOME" -type f -name "*.db" | fzf)
    fi
    if [[ find_tables -eq 1 ]]; then
        echo "now I should be finding the tables if any"
    fi
	# echo $db > "$home/connection"
	# echo "Connected to $db"
	# execute_query -c "$db" -m "list" -q "$sqite_version_query"
	# execute_query -c "$db" -m "list" -q "$query1"
	# exit "$?"
}

debug_this_script() {
    micro $0
    exit "$?"
}

default_function() {
    warn "Does connection exists?"
    # test_connection
    warn "Do tables exists?"
    # list_tables
    warn "Are tables selected?"
    # test_selection
    warn "What does user want?"
    connected=$(test_connection)
	debug "connected is $connected"
	if [[ $connected -eq 0 ]]; then
		warn "Not connected."
		prompt_connection
	else
		db=$(cat "$home/connection")
		warn "Connected to $db"
		# execute_query -c "$db" -m "list" -q "$sqite_version_query"
		execute_query -c "$db" -m "list" -q "$query1"
	fi
	err "error in default_function"
    exit 1
}

delete_sql() {
    warn "Desired Usage:"
    echo -e "
    sql delete <filter>
    sql delete -c [db] -t [table] <filter>
    
    where <filter> is a set of SQL conditions to be joined by AND/OR"

    warn "if no filter provided, do filter=\$(cat) as such:"
    echo "Provide filter (SQL conditions) [Ctrl+D]":
    filter=$(cat)
}

execute_query() {
	# sqlite3 -batch "$home/unnamed.db"                ".mode $mode" "$query" [most basic, db not provided]
	# sqlite3 -batch "path/to/.db"                         ".mode $mode" "$query" [db provided]
	# sqlite3 -batch "path/to/.db"          ".width x y z" ".mode $mode" "$query" [db+width provided]
	
	#example:
	# sqlite3 -batch "$HOME/archives/finances/finances.db" ".mode $mode" ".width 20 3 6 6 10 5 40 3" "select * from expenses"
	
	# defaults
	con=$DB
	mode=$MODE
	query="SELECT 'MISSING QUERY'"
	
	while [[ $# -gt 0 ]]; do
        case "$1" in
            -c)
                shift
                con="$1"
                ;;
            -m)
                shift
                mode="$1"
                ;;
            -w)
                shift
                widths="$1"
                ;;
            -q)
				shift
				query="$1"
				;;
            *)
                err "Unknown option: $1"
                exit 1
                ;;
        esac
        shift
    done

    # Output the values for debugging
    debug "Value of -c: $con"
    debug "Value of -m: $mode"
    debug "Value of -w: $widths"
	debug "Value of -q: $query"
	
	# TODO add width control
	sqlite3 "$con" ".mode $mode" "$query" -batch
}

_get() {
	if [ $# -eq 0 ]; then err "Missing attribute"; exit 1; fi

	case "$1" in
		conn* | db) cat "$home/connection" ; exit "$?" ;;
		tabl*) list_tables ; exit 1 ;;
		*) default_fn "$@" ;; #TODO
	esac
}

initialize() {
    debug "Initializing..."
    if [[ ! -d "$home" ]]; then
        mkdir "$home"
        touch "$home/connection";
    fi
}

input_query() {
	# Prompts user to enter an SQL query
	#TODO detect sql keywords and 
	echo "Enter SQL query (Ctrl+D when finished):" >&2
    query=$(cat)
	echo $query
}

insert_sql() {
    warn "Desired Usage:"
        echo -e "
        sql add
        sql add default
        sql add field1:value1 field2:value2 ..."
        
    if [ $# -eq 0 ]; then
        read -p "col1: " -t 9 col1
        warn "if empty, ABORT"
        read -p "col2: " -t 9 col2
        read -p "col3: " -t 9 col3
        read -p "col4: " -t 9 col4
        echo "$col1 $col2 $col3 $col4"
        exit 1
    fi
    
    case "$1" in
        def*) warn INSERT DEFAULT VALUES ; exit 1 ;;
        *) ;;
    esac
    
   warn "iterate and extract field:value"
   echo "$@" | cut -d':' -f1
   echo "$@" | cut -d':' -f2
}

list_tables() { #TODO may 20 ***********************************
    is_connected=$(test_connection)
    if [[ is_connected -eq 0 ]]; then
        warn "Not connected."
    else
		db=$(cat "$home/connection")
		debug "db=$db"
		debug "query= $table_list_query"
        execute_query -c "$db" -q "$table_list_query"
    fi
    exit "$?"
}

prompt_connection() {
    echo "Would you like to connect? [y/n]"
    err "syke, not implemented"
    exit 1
}

select_table() {
	if [[ $# -eq 0 ]]; then err "Missing argument [table]" ; exit 1 ; fi
	if [[ ! -d "$home" ]] || [[ ! -f "$home/connection" ]]; then warn "Not connected." ; exit 1 ; fi
	con=$(_get "connection")
	is_valid_table=$(test_is_table "$1")
	if [[ ! $is_valid_table -eq 1 ]]; then err "No such table in $con"; exit 1 ; fi
	echo "$1" > "$home/focal_table"
	exit "$?"
}

_set() {
    case "$1" in
        db) echo "set database $2" ;;
        ta??e*) echo "Set table/target $2" ;;
        *) echo "set $*" ;;
    esac
#    exit 1
}

# Help function to display usage information and option descriptions
show_help() {
    # ANSI color codes for colors without using \e[33m and \e[31m
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color

    echo "Usage: $(basename "$0") [OPTIONS]"
    echo "Options:"
    for option in "${!option_descriptions[@]}"; do
        printf "  ${GREEN}%-12s${NC} %s\n" "$option" "${option_descriptions[$option]}"
    done
    exit 0
}

show_usage() {
	warn 'edit aliases|variables|debug|help|...'
	exit 1
}

test_connection() {
	debug " --- Testing connection, return 1 if successful, 0 if not"
    con_file="$home/connection"
    if [[ ! -f "$con_file" ]]; then
        debug "$con_file does not exist"
        echo 0
	else
		con=$(cat "$con_file")
		debug "db name is $con"
		if [[ -z "$con" ]]; then echo 0
		else
            schema_version=$(execute_query -c "$con" -m "line" -q "$schema_version_pragma") 
            echo "$schema_version" >&2
			echo 1
		fi
	fi
	debug " --- Test over."
}

test_is_table() {
	err "Not implemented line 344"
}

unknown_arg_interpreter(){
    # for arg in args
    warn 'Is arg a "*"?'
    warn 'Is arg a table?'
    warn 'Is arg a column?'
    warn 'Is arg an identifier?'
    warn 'Is arg a sort keyword?'
    warn 'Is arg a filter keyword?'
    case0=$(test_is_globstar "$1") # * or all
    case1=$(test_is_table    "$@")
    case2=$(test_is_column   "$@")
    case3=$(test_is_id       "$@") # is integer
    case4=$(test_is_filter   "$@")
    case5=$(test_is_sort     "$@")
}

update_sql() {
    warn "Desired Usage:"
        echo -e "
        sql mod <filter> column1:value1 column2:value2 ..."
    warn "UPDATE <table> SET ( col1 [,col2,col3] = expr )... FROM <table> WHERE con1 AND/OR con2 AND/OR"
}

# Messages
debug() { if [[ $DEBUG -eq 1 ]]; then echo -e "\e[34m$@\e[0m" >&2; fi }
err() { echo -e "\e[31m$@\e[0m" 1>&2; }
warn(){ echo -e "\e[33m$@\e[0m"; }

#warnings
main "$@" #<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#=============================================================================
# Additional documentation
#=============================================================================

# SQL PROJECT *********************************************************************

#"sqlite3 -batch {db_filepath} \".mode {Q.mode}\" \"{Q.sql}\""
## example: sqlite3 -batch "$HOME/archives/finances/finances.db" ".mode column" ".width 20 3 6 6 10 5 40 3" "select * from expenses"
    # DB=$(echo $CONNECTED_DB | cut -d':' -f1)
    # target_table=$(echo $CONNECTED_DB | cut -d':' -f2)

### general commands

#sql                      -> run default (if not connected, connect. If no table specified, show tables. Else, select * all)
#sql connect, -c          -> fzf search db
#sql connect <*.db>.<tablename>       -> connect, fetch tables, print tables ,export db name
#sql tables               -> print tables
#sql <table>              -> print information about table
#sql set target <table_name>  -> export table name: DB: finances.db/expenses
#sql <filter> <user defined command>
#sql run|execute <SQL commands as is>

### select [DEFAULT OPERATION, DO NOT SPECIFY]

#sql *                    -> SELECT * [FROM TABLE]
#sql <id>...              -> SELECT * [FROM TABLE] WHERE id/rowid = <val> AND ...
#sql <column>...          -> SELECT c1,c2,c3,... [FROM TABLE WHERE ...] 
#sql <condition>...       -> SELECT [...] [FROM TABLE] WHERE con1 AND/OR con2 AND/OR con3
#sql <column> <condition>... [by <column><+|->] [limit:<value>] [offset:<value>]
#sql <*filter>            -> interpret as any non-commands as filter


#-> SELECT [DISTINCT] * | <column>... | <expr> AS [alias] ...
#   FROM <table>
#   WHERE <filter1> <filter2> <filter3> ...
#   GROUP BY <col>... HAVING expr
#   ORDER BY <term>...
#   LIMIT <val>
#   OFFSET <val>
#   

### insert

#sql add|insert [table] <column>:<value>...

#-> INSERT INTO <table> [(col1,col2,c3)] VALUES (cal1,val2,val3)
#-> INSERT INTO <table>                  VALUES ...
#-> INSERT INTO <table> DEFAULT VALUES

### update

#sql mod|update [table] <column>:<value>...

#-> UPDATE <table> SET ( col1 [,col2,col3] = expr )... FROM <table> WHERE con1 AND/OR con2 AND/OR

### delete

#sql del|delete [table] <condition>...

#-> DELETE FROM <table> WHERE con1 AND/OR con2 AND/OR con3 ...

### other commands

#sql --backup to <file>

#sql --dump ...

#sql --mode <csv|column|html|insert|line|list|tabs|tcl>

#sql --read <file>

#sql --width

#sql alter <table> <string>
#-> ALTER TABLE $table RENAME TO $string
#-> ALTER TABLE $table RENAME COLUMN $col TO $new-col
#-> ALTER TABLE $table ADD COLUMN $def
#-> ALTER TABLE $table DROP COLUMN $name

#sql attach
#-> ATTACH DATABASE <expr> AS <shema-name>

#sql rollback
#-> ROLLBACK TRANSACTION TO SAVEPOINT <savename>

#sql savepoint
#-> SAVEPOINT <savename>

# **************************************************************************
# REFERENCE TO TASKWARRIOR DOCUMENTATION
#cybersamurai@Luminous:~$ task help

#Usage: task                                       Runs rc.default.command, if specified.
#       task <filter> active                       Active tasks
#       task          add <mods>                   Adds a new task
#       task <filter> all                          All tasks
#       task <filter> annotate <mods>              Adds an annotation to an existing task
#       task <filter> append <mods>                Appends text to an existing task description
#       task <filter> blocked                      Blocked tasks
#       task <filter> blocking                     Blocking tasks
#       task <filter> burndown.daily               Shows a graphical burndown chart, by day
#       task <filter> burndown.monthly             Shows a graphical burndown chart, by month
#       task <filter> burndown.weekly              Shows a graphical burndown chart, by week
#       task          calc <expression>            Calculator
#       task          calendar [due|<month>        Shows a calendar, with due tasks marked
#       <year>|<year>] [y]
#       task          colors [sample | legend]     All colors, a sample, or a legend
#       task          columns [substring]          All supported columns and formatting styles
#       task          commands                     Generates a list of all commands, with
#                                                  behavior details
#       task <filter> completed                    Completed tasks
#       task          config [name [value | '']]   Change settings in the task configuration
#       task          context [<name> |            Set and define contexts (default filters /
#       <subcommand>]                              modifications)
#       task <filter> count                        Counts matching tasks
#       task <filter> delete <mods>                Deletes the specified task
#       task <filter> denotate <pattern>           Deletes an annotation
#       task          diagnostics                  Platform, build and environment details
#       task <filter> done <mods>                  Marks the specified task as completed
#       task <filter> duplicate <mods>             Duplicates the specified tasks
#       task <filter> edit                         Launches an editor to modify a task directly
#       task          execute <external command>   Executes external commands and scripts
#       task <filter> expenses                     Reports all expenses
#       task <filter> export [<report>]            Exports tasks in JSON format
#       task <filter> ghistory.annual              Shows a graphical report of task history, by
#                                                  year
#       task <filter> ghistory.daily               Shows a graphical report of task history, by
#                                                  day
#       task <filter> ghistory.monthly             Shows a graphical report of task history, by
#                                                  month
#       task <filter> ghistory.weekly              Shows a graphical report of task history, by
#                                                  week
#       task          help ['usage']               Displays this usage help text
#       task <filter> history.annual               Shows a report of task history, by year
#       task <filter> history.daily                Shows a report of task history, by day
#       task <filter> history.monthly              Shows a report of task history, by month
#       task <filter> history.weekly               Shows a report of task history, by week
#       task <filter> ids                          Shows the IDs of matching tasks, as a range
#       task          import [<file> ...]          Imports JSON files
#       task <filter> information                  Shows all data and metadata
#       task <filter> last_insert                  Reports all info on last inserted task
#       task <filter> list                         Most details of tasks
#       task          log <mods>                   Adds a new task that is already completed
#       task          logo                         Displays the Taskwarrior logo
#       task <filter> long                         All details of tasks
#       task <filter> ls                           Few details of tasks
#       task <filter> minimal                      Minimal details of tasks
#       task <filter> modify <mods>                Modifies the existing task with provided
#                                                  arguments.
#       task <filter> newest                       Newest tasks
#       task          news                         Displays news about the recent releases
#       task <filter> next                         Most urgent tasks
#       task <filter> oldest                       Oldest tasks
#       task <filter> overdue                      Overdue tasks
#       task <filter> prepend <mods>               Prepends text to an existing task
#                                                  description
#       task <filter> projects                     Shows all project names used
#       task <filter> purge                        Removes the specified tasks from the data
#                                                  files. Causes permanent loss of data.
#       task <filter> ready                        Most urgent actionable tasks
#       task <filter> recurring                    Recurring Tasks
#       task          reports                      Lists all supported reports
#       task          show [all | substring]       Shows all configuration variables or subset
#       task <filter> simple                       Simple list of open tasks by project
#       task <filter> start <mods>                 Marks specified task as started
#       task <filter> stats                        Shows task database statistics
#       task <filter> stop <mods>                  Removes the 'start' time from a task
#       task <filter> summary                      Shows a report of task status by project
#       task          synchronize [initialize]     Synchronizes data with the Taskserver
#       task <filter> tags                         Shows a list of all tags used
#       task [filter] timesheet                    Summary of completed and started tasks
#       task <filter> trash                        List all deleted tasks
#       task          udas                         Shows all the defined UDA details
#       task <filter> unblocked                    Unblocked tasks
#       task          undo                         Reverts the most recent change to a task

