#!/bin/zsh


git_msg="Your branch is ahead of 'upstream/dev'"

git status | grep -wq "$git_msg"
is_pending_commits=$?

if [ $is_pending_commits -eq 0 ]; then
  echo "Pending commits"
else
  echo "No pending commits"
fi


# 1 = pending commits
# 0 = no pending commuts
