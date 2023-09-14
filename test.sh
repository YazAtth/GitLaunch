#!/bin/zsh

#echo '{ "name": ["hi\n", "there"] }' | jq ".name"

string='{ "name": ["hi\n", "there"] }'

#string_parsed=$(sed 's/\\n/\\\\n/g' <<< "$string")
#
#gitignore_items=$(jq ".name" <<< "$string_parsed")
#
#echo "$gitignore_items"


string_parsed=$(jq ".name" <<< "$string")
echo "$string_parsed"
