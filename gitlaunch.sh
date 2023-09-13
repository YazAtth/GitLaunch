#!/bin/bash

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


repoName=${1? missing name of repo name}

# Shift the processed options and their arguments
shift

isRepoPublic=false

GREEN_BOLD='\033[1;32m'
WHITE='\033[0;37m'
BLUE='\033[1;36m'



if ! [ -f README.md ]; then
  echo -e "$GREEN_BOLD* README.md file not found. Creating one...$WHITE"
  touch README.md
fi


if ! [ -d .git ]; then

  echo -e $GREEN_BOLD
  echo "* Git not intialised in current directory"
  echo "* Initialising current repository with git..."

  echo -e $WHITE

  git init >/dev/null
  git add . >/dev/null
  git commit -m "FEAT: Setup (first commit)" >/dev/null

fi


while getopts "p" opt; do
  case $opt in
    p)
      isRepoPublic=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Shift the processed options and their arguments
shift $((OPTIND-1))

echo ""



if ! $isRepoPublic; then
  # echo -e "$GREEN_BOLD* Creating private GitHub repo.. $WHITE"
  # gh repo create $repoName --private --source=$PWD --remote=upstream --push

  loading_message="Creating private GitHub repo..." 

  spinner_pid=
  start_spinner "Creating private GitHub repo..."


  exec 3>&1
  number=$(gh repo create $repoName --private --source=$PWD --remote=upstream --push 2>&1 >/dev/null)
  exec 1>&3

  stop_spinner

  echo "Hello world" 
  echo -e "Number is $number"


else
  echo -e "$GREEN_BOLD* Creating public Github repo... $WHITE"
  # gh repo create $repoName --public --source=$PWD --remote=upstream --push
fi

echo -e "$GREEN_BOLD* Created repo on Github.com$WHITE"




echo "END"