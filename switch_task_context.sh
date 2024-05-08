#!/bin/bash

set_emoji() {
    if [ -z "$1" ]; then
        emoji=""
        task context none
        PS1=$PS
        return 0
    fi

    case "$1" in
        none)
            emoji=""
            task context none
            PS1=$PS
            return 0
            ;;
        home)
            emoji="🏠"
            task context home
            ;;
        work)
            emoji="💼"
            task context work
            ;;
        jbap)
            emoji="📝"
            task context jbap
            ;;
        schl)
            emoji="🎓"
            task context schl
            ;;
        sdqu)
            emoji="📜"
            task context sdqu
            ;;
        *)
            echo -e "\e[31mInvalid argument. \e[33mUsage: swch {home|work|jbap|schl|sdqu}\e[0m"
            return 1
            ;;
    esac
    
    PS1="\[\e[5;92m\]\$(date +'%H:%M')\[\e[0m\] $emoji \[\033[01;34m\]\w\[\033[00m\] \[\e[5m\]⚡\[\e[0m\]"
}

set_emoji "$1"
