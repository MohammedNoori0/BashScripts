#!/bin/bash

echo "System Information Report"
echo "========================="
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Logged in Users:"
who
echo "Memory Usage:"
free -h
echo "Disk Usage:"
df -h
echo "CPU Load Average:"
uptime | awk -F'load average:' '{ print $2 }'

