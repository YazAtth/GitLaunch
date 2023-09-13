#!/bin/bash

repoName=${1? missing name of repo name}

# Shift the processed options and their arguments
shift

isRepoPublic=false

GREEN_BOLD='\033[1;32m'
WHITE='\033[0;37m'


if ! [ -f README.md ]; then
  echo -e "$GREEN_BOLD* README.md file not found. Creating one...$WHITE"
  touch README.md
fi


if ! [ -d .git ]; then

  echo -e $GREEN_BOLD
  echo "* Git not intialised in current directory"
  echo "* Initialising current repository with git..."
  echo -e $WHITE

  


  git init
  git add .
  git commit -m "FEAT: Setup (first commit)"
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
  echo -e "$GREEN_BOLD* Creating private GitHub repo.. $WHITE"
  gh repo create $repoName --private --source=$PWD --remote=upstream --push
else
  echo -e "$GREEN_BOLD* Creating public Github repo... $WHITE"
  gh repo create $repoName --public --source=$PWD --remote=upstream --push
fi

echo -e "$GREEN_BOLD* Created repo on Github.com$WHITE"




