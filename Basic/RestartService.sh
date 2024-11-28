#!/bin/bash

SERVICE="apache2"
if ! systemctl is-active --quiet $SERVICE; then
    echo "$SERVICE is not running! Restarting..."
    systemctl restart $SERVICE
    echo "$SERVICE has been restarted."
else
    echo "$SERVICE is running."
fi

