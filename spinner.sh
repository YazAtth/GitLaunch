#!/bin/bash

BLUE='\033[1;36m'
WHITE='\033[0;37m'
GREEN_BOLD='\033[1;32m'



function start_spinner {
    set +m
    echo -en "$GREEN_BOLD* $1$WHITE     "
    # while : ; do for X in '┤' '┘' '┴' '└' '├' '┌' '┬' '┐' ; do echo -en "\b$X" ; sleep 0.1 ; done ; done
    # { while : ; do for X in '  •     ' '   •    ' '    •   ' '     •  ' '      • ' '     •  ' '    •   ' '   •    ' '  •     ' ' •      ' ; do echo -en "\b\b\b\b\b\b\b\b$X" ; sleep 0.1 ; done ; done & } 2>/dev/null
    
    # { while : ; do for X in '' ; do echo -en "\b\b\b\b\b\b\b\b$X" ; sleep 0.1 ; done ; done & } 2>/dev/null

    { while : ; do for X in ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ ; do echo -en "\b$BLUE$X$WHITE" ; sleep 0.1 ; done ; done & } 2>/dev/null

    
    spinner_pid=$!
}

function stop_spinner {
    { kill -9 $spinner_pid && wait; } 2>/dev/null
    set -m
    echo -en "\033[2K\r"
}

# spinner_pid=
# start_spinner "I'm thinking "

# # echo "lol"
# # sleep 2

# # echo "lol"
# sleep 2

# stop_spinner