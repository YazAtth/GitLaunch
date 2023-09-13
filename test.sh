#!/bin/bash

source ./spinner.sh


spinner_pid=
start_spinner "I'm thinking "

# sleep 2

# print_message "lol" "I'm thinking "
# sleep 2

random_text | print_message "I'm thinking "
sleep 2

random_text | print_message "I'm thinking "
sleep 5

stop_spinner


