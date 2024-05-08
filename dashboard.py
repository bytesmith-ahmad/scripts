#!usr/bin/bash

import curses
import datetime

# Function to initialize curses
def init_curses():
    stdscr = curses.initscr()
    curses.start_color()
    curses.noecho()
    curses.cbreak()
    stdscr.keypad(True)
    curses.curs_set(False)
    return stdscr

# Function to display dashboard
def display_dashboard(stdscr):
    # Get current date and time
    now = datetime.datetime.now()

    # Example pending data
    pending_assignments = ["Assignment 1", "Assignment 2", "Assignment 3"]
    pending_expenses = ["Expense 1", "Expense 2", "Expense 3"]
    pending_tasks = ["Task 1", "Task 2", "Task 3"]

    # Clear the screen
    stdscr.clear()

    # Display current time
    stdscr.addstr(0, 0, f"Current Time: {now.strftime('%Y-%m-%d %H:%M:%S')}")

    # Display pending assignments
    stdscr.addstr(2, 0, "Pending Assignments:")
    for i, assignment in enumerate(pending_assignments):
        stdscr.addstr(3 + i, 2, f"{i + 1}. {assignment}")

    # Display pending expenses
    stdscr.addstr(2, 30, "Pending Expenses:")
    for i, expense in enumerate(pending_expenses):
        stdscr.addstr(3 + i, 32, f"{i + 1}. {expense}")

    # Display pending tasks
    stdscr.addstr(2, 60, "Pending Tasks:")
    for i, task in enumerate(pending_tasks):
        stdscr.addstr(3 + i, 62, f"{i + 1}. {task}")

    # Refresh the screen
    stdscr.refresh()

    # Wait for user input to exit
    stdscr.getch()

# Main function
def main():
    stdscr = init_curses()
    display_dashboard(stdscr)
    curses.endwin()

if __name__ == "__main__":
    main()
