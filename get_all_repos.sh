#!/bin/bash

# Notes:
# Corpus:
# Specifically searching for ~/${shell}_history
# Looking for bash / zsh files on github
# Looking for code sections on stackoverflow
# do forks manually?

#num=1

num=`find out -name "out*" -type f | awk -F'[_\.]' '{print $2}' | sort -n -r | head -n 1`

while true
do
    curl -s -u lengstrom:$ghat "https://api.github.com/repositories?since=$num" | jq '[.[] | {"id": .id, "name": .full_name, "tree": .trees_url, "fork":.fork}]' > out/out_$num.json
    num=`cat out/out_$num.json | jq '.[-1] | .id'`
    if [ $(($num)) -gt $((49615800)) ]
    then
        break
    fi
    echo "finished ${num}"
done

#curl -u lengstrom:$ghat "https://api.github.com/search/code?q=filename:bash_history&page=1&per_page=100"
