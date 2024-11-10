#!/bin/bash

THRESHOLD=80

echo "Disk usage report:"

df -h | awk '{print $5 " " $1}' | while read output; do
    usage=$(echo $output | awk '{print $1}' | sed 's/%//g')
    partition=$(echo $output | awk '{print $2}')
    if [ $usage -ge $THRESHOLD ]; then
        echo "Warning: Partition $partition is at $usage% usage!"
    fi
done

