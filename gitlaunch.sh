#!/bin/bash



dependencies=("curl" "jq" "git" "gh")
is_dependency_missing=false

# Check for the presence of each dependency
for dependency in "${dependencies[@]}"; do
    if ! command -v "$dependency" &>/dev/null; then
        echo "Error: required dependency '$dependency' is not installed. Please install it and try again."
        is_dependency_missing=true
    fi
done

if $is_dependency_missing; then
    exit 1
fi



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

    local logging_text=$(cat)

    tput rc  # Restore the cursor position
    echo -e "\033[K$logging_text"  # Erase to the end of the line and print the new message
    tput sc  # Save the cursor position again


    echo -en "$GREEN_BOLD* $1$WHITE     "
}


function print_message_test {
  local logging_text=$(cat)
}


repoName=${1? missing name of repo name}

# Shift the processed options and their arguments
shift

isRepoPublic=false

GREEN_BOLD='\033[1;32m'
WHITE='\033[0;37m'
BLUE='\033[1;36m'
RED='\033[1;31m'



if ! [ -f README.md ]; then
  echo -e "* README.md file not found. Creating one..."
  touch README.md
fi

if ! [ -f .gitignore ]; then
  echo -e "* .gitignore file not found. Creating one..."
  touch .gitignore
fi


if ! [ -d .git ]; then

  echo -e "* Git not intialised in current directory\n* Initialising current repository with git..."

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
  start_spinner "$loading_message"

#  number=$(gh repo create $repoName --private --source=$PWD --remote=upstream --push)

#  gh repo create $repoName --private --source=$PWD --remote=upstream --push 2>&1 | print_message "Creating private GitHub repo..."
#  github_exit_code=$?
#  echo "error code: $github_exit_code"

  github_output=$(gh repo create $repoName --private --source=$PWD --remote=upstream --push 2>&1)
  github_exit_code=$?

  echo "$github_output" | print_message "$loading_message"


  stop_spinner


else
  echo -e "$GREEN_BOLD* $loading_message $WHITE"
  # gh repo create $repoName --public --source=$PWD --remote=upstream --push
fi



if [ $github_exit_code -eq 0 ]; then
  echo -ne "\n$GREEN_BOLD* GitHub repo created successfully!$WHITE\n\n"
else
  echo -ne "$RED* Error creating GitHub repo.$WHITE\n\n"

  rm README.md
  rm -rf .git

  exit 1
fi



rm README.md
rm -rf .git
