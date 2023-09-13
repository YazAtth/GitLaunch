#!/bin/bash

BLUE='\033[1;36m'
WHITE='\033[0;37m'
GREEN_BOLD='\033[1;32m'

function start_spinner {
    set +m
    tput sc  # Save the cursor position
    echo -en "$GREEN_BOLD* $1$WHITE     "

    { while : ; do for X in ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ ; do echo -en "\b$BLUE$X$WHITE" ; sleep 0.1 ; done ; done & } 2>/dev/null

    spinner_pid=$!
}

function stop_spinner {
    { kill -9 $spinner_pid && wait; } 2>/dev/null
    set -m
    echo -en "\033[2K\r"
}

function print_message {

    logging_text=$(cat)

    tput rc  # Restore the cursor position
    echo -e "\033[K$logging_text"  # Erase to the end of the line and print the new message
    tput sc  # Save the cursor position again


    echo -en "$GREEN_BOLD* $1$WHITE     "
}

function random_text {
    echo "Words iodjksfkdls dksj ldk"
    echo "Words iodjksfkdls dksj ldk"
    sleep 1
    echo "Words iodjksfkdls dksj ldk"
    sleep 2
    echo "Words iodjksfkdls dksj ldk"

}

# spinner_pid=
# start_spinner "I'm thinking "

# sleep 2

# print_message "lol" "I'm thinking "
# sleep 2

# print_message "lol 2" "I'm thinking "
# sleep 2

# stop_spinner
