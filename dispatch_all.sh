#!/bin/bash

#get_all_repos.sh 13429383 20000000
# 17429383 -> 21429383
# 13429383 -> 17429383
iter=$((2000000))
start=$((13429383))
end=$((50000000))

source stack.sh

stack_new a
source push_all_tokens.sh
while [ $start -lt $end ];
do
    stack_pop a n
    ./get_all_repos.sh $start $(($start + $iter)) "$n" &
    start=$(($start + $iter))
done
