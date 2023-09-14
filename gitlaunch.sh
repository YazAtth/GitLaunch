#!/bin/bash


GREEN_BOLD='\033[1;32m'
GREEN='\033[0;32m'
DEFAULT_COLOUR='\033[0m'
BLUE='\033[1;36m'
RED='\033[1;31m'
YELLOW='\033[1;33m'

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

# Check if the user requested help
if [[ "$1" = "-h" ]]; then

  echo -ne "\nUsage: gitlaunch [-h] [-p] [-i template]\n"
  echo "Options:"
  echo "  -h        Display this help message and exit"
  echo "  -p        Set repository as public (default is private)"
  echo "  -i        Specify a custom .gitignore template"


  echo -ne "\n\n$GREEN----------------------------------------------------------------------------\n"
  echo -ne "In order to run the script like a command: add the line\n\n"
  echo -ne "  ${GREEN_BOLD}alias gitlaunch='$PWD/gitlaunch.sh'$GREEN\n\n"
  echo "to the '~/.zshrc' file"
  echo -ne "\nNOTE: You will have to change the path if you move this script to a \ndifferent directory.\n"
  echo -ne "----------------------------------------------------------------------------$DEFAULT_COLOUR\n\n"



  exit 0
fi






function populate_gitignore {
  required_gitignore_template=$1

  # URL you want to send the GET request to
  url="https://api.github.com/gitignore/templates/${required_gitignore_template}"

  github_auth_token=$(gh auth token)

  # Send a GET request and store the response in a variable
  response=$(curl -s -H "Authorization: Bearer $github_auth_token" "$url")

  # Check if the request was successful (HTTP status code 200)
  if [ $? -eq 0 ]; then
      custom_gitignore="# Custom Files to Ignore"$'\n'".idea"$'\n'".DS_Store"$'\n\n'
      requested_gitignore=$(echo "$response" | jq -r ".source")

      if [ "$requested_gitignore" != "null" ]; then
        total_gitignore="${custom_gitignore}${requested_gitignore}"
      else
        echo -e "${YELLOW}Warning: Could not find a .gitignore template for '$required_gitignore_template$DEFAULT_COLOUR'"
        total_gitignore="${custom_gitignore}"
      fi


      echo "$total_gitignore" > .gitignore
#      echo "$total_gitignore" > out.txt


  else
      echo "GET request failed."
  fi

}


function start_spinner {
    set +m
    tput sc  # Save the cursor position
    echo -en "$GREEN_BOLD* $1$DEFAULT_COLOUR     "

    { while : ; do for X in ⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷ ; do echo -en "\b$BLUE$X$DEFAULT_COLOUR" ; sleep 0.1 ; done ; done & } 2>/dev/null

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


    echo -en "$GREEN_BOLD* $1$DEFAULT_COLOUR     "
}


function print_message_test {
  local logging_text=$(cat)
}


repoName=${1? missing name of repo name}

# Shift the processed options and their arguments
shift

isRepoPublic=false
isCustomGitignoreRequired=false



while getopts "pi:" opt; do
  case $opt in
    p)
      isRepoPublic=true
      ;;
    i)
      isCustomGitignoreRequired=true
      required_gitignore_template="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Use 'gitlaunch -h' for help"
      exit 1
      ;;
  esac
done


if ! [ -f README.md ]; then
  echo -e "* README.md file not found. Creating one..."
  touch README.md
fi

if ! [ -f .gitignore ]; then
  echo -e "* .gitignore file not found. Creating one..."
  touch .gitignore

  if $isCustomGitignoreRequired; then
    populate_gitignore "$required_gitignore_template"
#  else
#    echo "lol"
  fi

fi





if ! [ -d .git ]; then
  echo -e "${YELLOW}Warning: Git not intialised in current directory$DEFAULT_COLOUR\n* Initialising current repository with git..."

  git init >/dev/null
  git add . >/dev/null
  git commit -m "FEAT: Setup (first commit)" >/dev/null

fi


# Shift the processed options and their arguments
shift $((OPTIND-1))

echo ""



if ! $isRepoPublic; then
  # echo -e "$GREEN_BOLD* Creating private GitHub repo.. $DEFAULT_COLOUR"
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
  echo -e "$GREEN_BOLD* $loading_message $DEFAULT_COLOUR"
  # gh repo create $repoName --public --source=$PWD --remote=upstream --push
fi



if [ $github_exit_code -eq 0 ]; then
  echo -ne "\n$GREEN_BOLD* GitHub repo created successfully!$DEFAULT_COLOUR\n\n"
else
  echo -ne "$RED* Error creating GitHub repo.$DEFAULT_COLOUR\n\n"

#  rm README.md
#  rm -rf .git
#  rm .gitignore

  exit 1
fi



#rm README.md
#rm -rf .git
#rm .gitignore
