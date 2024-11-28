#!/bin/bash

LOGFILE="/var/log/sys_monitor.log"
CPU_THRESHOLD=80
MEM_THRESHOLD=80

cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
    echo "$(date): High CPU usage: $cpu_usage%" >> $LOGFILE
fi

if (( $(echo "$mem_usage > $MEM_THRESHOLD" | bc -l) )); then
    echo "$(date): High Memory usage: $mem_usage%" >> $LOGFILE
fi

