#!/bin/zsh

# WARNING: Make sure it is "false" in production
is_debug_mode=false

GREEN_BOLD='\033[1;32m'
GREEN='\033[0;32m'
DEFAULT_COLOUR='\033[0m'
BLUE='\033[1;36m'
RED='\033[1;31m'
YELLOW='\033[1;33m'

function main() {

  # Add "--debug" to run the cleanup function
  # WARNING: Never run in production
  if [[ "$1" = "--debug" ]]; then
    echo -en "RUNNING IN DEBUG MODE\n\n"
    is_debug_mode=true
    shift
  fi


  check_for_missing_dependencies

  # Check if the user requested help
  if [[ "$1" = "-h" ]]; then
    print_help
  fi


  repo_name=${1? missing name of repo name}
  shift # Shift the processed options and their arguments so we can ignore the filename argument and read the flags

  # Handle flags
  repo_visibility="private"
  is_custom_gitignore_required=false

  while getopts "pi:" opt; do
    case $opt in
      p)
        repo_visibility="public"
        ;;
      i)
        is_custom_gitignore_required=true
        required_gitignore_template="$OPTARG"
        ;;
      \?)
        echo "Invalid option: -$OPTARG" >&2
        echo "Use 'gitlaunch -h' for help"
        exit 1
        ;;
    esac
  done


  # Adds README.md if one doesn't already exist
  if ! [ -f README.md ]; then
    echo -e "* README.md file not found. Creating one..."
    touch README.md
  fi

  # Adds a gitignore of one doesn't already exist.
  if ! [ -f .gitignore ]; then
    echo -e "* .gitignore file not found. Creating one..."
    touch .gitignore

    if $is_custom_gitignore_required; then
      populate_gitignore "$required_gitignore_template"
    fi
  fi



  # Initialises git in the local directory if not already initialised
  if ! [ -d .git ]; then
    echo -e "${YELLOW}Warning: Git not intialised in current directory$DEFAULT_COLOUR\n* Initialising current repository with git..."

    git init >/dev/null
    git add . >/dev/null
    git commit -m "FEAT: Setup (first commit)" >/dev/null
  else
    git_msg="nothing to commit, working tree clean"

    git status | grep -wq "$git_msg"
    is_pending_commits=$?

    # If directory is initialised with git but no commits have been made
    if [ $is_pending_commits -eq 1 ]; then
      git add . >/dev/null
      git commit -m "FEAT: Setup (first commit)" >/dev/null
    fi

  fi


  # Shift the processed options and their arguments
  shift $((OPTIND-1))
  echo ""


  create_github_repo


  if [ $github_exit_code -eq 0 ]; then
    echo -ne "\n$GREEN_BOLD✓ GitHub repo created successfully!$DEFAULT_COLOUR\n\n"
  else
    echo -ne "$RED* Error creating GitHub repo.$DEFAULT_COLOUR\n\n"

    debug_cleanup


    exit 1
  fi



  debug_cleanup



}










function check_for_missing_dependencies {

  # Check if required dependencies are installed before running
  dependencies=("curl" "jq" "git" "gh")
  declare -A dependency_brew_command=(["jq"]="brew install jq" ["git"]="brew install git" ["gh"]="brew install gh")

  is_dependency_missing=false
  for dependency in "${dependencies[@]}"; do
      if ! command -v "$dependency" &>/dev/null; then
          echo -ne "\n${RED}Error$DEFAULT_COLOUR: required dependency '$dependency' is not installed.\n"
          echo -ne "Please install it using the command '$GREEN_BOLD${dependency_brew_command[$dependency]}$DEFAULT_COLOUR' and try again.\n\n"
          is_dependency_missing=true
      fi
  done
  if $is_dependency_missing; then # Exit the program if at least one dependency is missing
      exit 1
  fi

}


function print_help {
  echo -ne "\nUsage: gitlaunch <repo_name> [-p] [-i template]\n"
  echo "Options:"
  echo "  -p        Set repository as public (default is private)"
  echo "  -i        Specify a custom .gitignore template"

  echo -ne "\n\n$GREEN----------------------------------------------------------------------------\n"
  echo -ne "In order to run the script like a command: add the line\n\n"
  echo -ne "  ${GREEN_BOLD}alias gitlaunch='$PWD/gitlaunch.sh'$GREEN\n\n"
  echo "to the '~/.zshrc' file"
  echo -ne "\nNOTE: You will have to change the path if you move this script to a \ndifferent directory.\n"
  echo -ne "----------------------------------------------------------------------------$DEFAULT_COLOUR\n\n"

  exit 0
}


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
      requested_gitignore=$(jq -r ".source" <<< "$response")

      if [ "$requested_gitignore" != "null" ]; then
        total_gitignore="${custom_gitignore}${requested_gitignore}"
      else
        echo -e "${YELLOW}Warning: Could not find a .gitignore template for '$required_gitignore_template$DEFAULT_COLOUR'"
        total_gitignore="${custom_gitignore}"
      fi


      if [ "$is_debug_mode" = true ]; then
        echo "$total_gitignore" > out.txt
      else
        echo "$total_gitignore" > .gitignore
      fi



  else
      echo "GET request failed."
  fi

}


function start_spinner {
    local spacing="          "

    set +m
    tput sc  # Save the cursor position
    echo -en "$GREEN_BOLD* $1$DEFAULT_COLOUR  $spacing"

    { while : ; do for X in "⣾$spacing" "⣽$spacing" "⣻$spacing" "⢿$spacing" "⡿$spacing" "⣟$spacing" "⣯$spacing" "⣷$spacing"; do echo -en "\b\b\b\b\b\b\b\b\b\b\b$BLUE$X$DEFAULT_COLOUR"; sleep 0.1; done; done & } 2>/dev/null



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

function create_github_repo {

  loading_message="Creating $repo_visibility GitHub repo..."

  spinner_pid=
  start_spinner "$loading_message"

  github_output=$(gh repo create $repo_name --$repo_visibility --source=$PWD --remote=upstream --push 2>&1)
  github_exit_code=$?

  echo "$github_output" | print_message "$loading_message"

  stop_spinner
}

function debug_cleanup {

  echo -ne "\n\n\n"

  if [ $is_debug_mode = true ]; then
    rm README.md
    rm -rf .git
    rm .gitignore
    gh repo delete "$repo_name" --yes
  fi

}


main "$@"; exit
