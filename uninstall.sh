#!/bin/bash

# Checking if the service is already active
if sudo systemctl is-active --quiet transferupload; then
    # Service is active, stop it
    echo "Stopping transferupload service..."
    sudo systemctl stop transferupload
else
    # Service is not active, no need to stop it
    echo "transferupload service is already stopped. Skipping..."
fi

# Remove systemd service
echo "Removing transferupload service..."
sudo systemctl disable transferupload
sudo rm /lib/systemd/system/transferupload.service

# Remove log files and log file paths
echo "Removing log files..."
sudo rm /var/log/transferupload/log.log
sudo rm /var/log/transferupload/error.log
sudo rmdir /var/log/transferupload

# Remove configuration file and configuration file path
echo "Removing configuration file..."
sudo rm /etc/transferupload/.env
sudo rmdir /etc/transferupload

echo "Uninstallation completed."