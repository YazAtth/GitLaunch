#!/bin/zsh


git_msg="Your branch is up to date with 'upstream/dev'."

git status | grep -wq "$git_msg"
echo $?
