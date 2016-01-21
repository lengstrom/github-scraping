#!/bin/bash

# Notes:
# Corpus:
# Specifically searching for ~/${shell}_history
# Looking for bash / zsh files on github
# Looking for code sections on stackoverflow
# do forks manually?

#num=1
source stack.sh
max=$(($2))
min=$(($1))
num=$(($1))
ghkey=$3

reset_script() {
    sleep 5
    echo "resetting..."
    ./get_all_repos.sh "$1" "$2" "${ghkey}"
    echo "Permenantly ending $min -> $max with key $3"
    exit
}

num=`find out2 -name "out2*" -type f | awk -F'[_\.]' '{print $2}' | awk -v mini=$min '{if($1==$1+0 && $1>mini)print $1}' | awk -v maxi=$max '{if($1==$1+0 && $1<maxi)print $1}' | sort -r -n | head -n 1`
if [ "g$num" = "g" ]; then
    num=$(($min))
fi

echo "$max, $min, $num"

echo $ghkey
nn=$((0))
while true
do
    cmd=`echo curl -s -u $ghkey "https://api.github.com/repositories?since=$num"`
    #echo $cmd
    {
        res=`$cmd`
    } || {
        echo "exiting..."
        exit
    }
    if [[ $res == *"rate limit exceeded for"* ]];
    then
        reset_script
        echo "Resetting: 0"
        stack_pop $stackname ghkey
        continue
    fi

    if [ "$num" = " " ];
    then
        reset_script
        stack_pop $stackname ghkey
        num=`find out2 -name "out2*" -type f | awk -F'[_\.]' '{print $2}' | awk -v mini=$min '{if($1==$1+0 && $1>mini)print $1}' | awk -v maxi=$max '{if($1==$1+0 && $1<maxi)print $1}' | sort -r -n | head -n 1`
        echo "Resetting: 1"
        num=$(($num+1))
        continue
    fi

    if [ $(($num)) -gt $max ];
    then
        exit
    fi
    
    {
        if [ -f out2/out2_$num.json ]; then
            echo "File already exists!"
            nn=$(($nn + 1))
            if [ $(($nn)) -gt 3 ];
            then
                reset_script
            fi
            
            num=`find out2 -name "out2*" -type f | awk -F'[_\.]' '{print $2}' | awk -v mini=$min '{if($1==$1+0 && $1>mini)print $1}' | awk -v maxi=$max '{if($1==$1+0 && $1<maxi)print $1}' | sort -r -n | head -n 1`
            echo "Resetting: 2"
            num=$(($num+1))
        else
            nn=$((0))
        fi
        echo $res | jq '[.[] | {"id": .id, "name": .full_name, "tree": .trees_url, "fork":.fork}]' > out2/out2_$num.json
        if [ ! -f out2/out2_$num.json ]; then
            echo "File not found!"
        fi
        echo "finished ${num}"
        num=`cat out2/out2_$num.json | jq '.[-1] | .id'`
        if [ $(($num)) -gt $((49615800)) ]
        then
            break
        fi
    } || {
        reset_script
        echo "Failed!"
        stack_pop $stackname ghkey
        num=`find out2 -name "out2*" -type f | awk -F'[_\.]' '{print $2}' | awk -v mini=$min '{if($1==$1+0 && $1>mini)print $1}' | awk -v maxi=$max '{if($1==$1+0 && $1<maxi)print $1}' | sort -r -n | head -n 1`
        echo "Resetting: 3"
        num=$(($num+1))
    }

done
