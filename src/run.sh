#!/bin/bash

# Define log file paths
LOG_FILE="/var/log/transferupload/log.log"
ERROR_FILE="/var/log/transferupload/error.log"

# Source the .env file
if [ -f /etc/transferupload/.env ]; then
    source /etc/transferupload/.env
else
    echo "Error: .env file not found. Exiting main.sh." >&2
    exit 1
fi

# Delay transferupload.service from starting right away.
# upon reboot so that there is time for any dependencies to load first; otherwise, 
# transferupload.service won’t start automatically and has to be started manually.
sleep 30

# Output the date/time in the logs (STDOUT & STDERR separately)
# and execute the main script.
{ $HOME_PATH/transferupload/src/main.sh | while IFS= read -r line; do
    echo "$(date +'%Y-%m-%d %H:%M:%S') $line"
done >> $LOG_FILE; } 2>&1 | while IFS= read -r line; do
    echo "$(date +'%Y-%m-%d %H:%M:%S') $line"
done >> $ERROR_FILE