#!/bin/bash

required_gitignore_template="Java"

# URL you want to send the GET request to
url="https://api.github.com/gitignore/templates/${required_gitignore_template}"

# Send a GET request and store the response in a variable
response=$(curl -s "$url")

# Check if the request was successful (HTTP status code 200)
if [ $? -eq 0 ]; then
    custom_gitignore="# Custom Files to Ignore"$'\n'".idea"$'\n'".DS_Store"$'\n\n'
    requested_gitignore=$(echo "$response" | jq -r ".source")

#    echo "$requested_gitignore"

    if [ "$requested_gitignore" != "null" ]; then
      total_gitignore="${custom_gitignore}${requested_gitignore}"
    else
      total_gitignore="${custom_gitignore}"
    fi

#    echo "$total_gitignore"

    echo "$total_gitignore" > out.txt

else
    echo "GET request failed."
fi



