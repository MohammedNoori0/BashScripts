#!/bin/bash

DAYS=7

for user in $(getent passwd | awk -F: '$3 >= 1000 {print $1}'); do
    exp_date=$(chage -l $user | grep "Account expires" | awk -F: '{print $2}')
    if [ "$exp_date" != " never" ]; then
        exp_sec=$(date -d "$exp_date" +%s)
        now_sec=$(date +%s)
        diff_days=$(( ($exp_sec - $now_sec) / 86400 ))
        if [ $diff_days -le $DAYS ]; then
            echo "User $user's account will expire in $diff_days days"
        fi
    fi
done

