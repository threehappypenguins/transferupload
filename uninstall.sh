#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo."
  exit 1
fi

# Get the username of the user who invoked sudo
sudo_user="$SUDO_USER"

# Get the home directory of the sudo user
HOME=$(eval echo ~$sudo_user)

# Checking if the service is already active
if systemctl is-active --quiet transferupload; then
    # Service is active, stop it
    echo "Stopping transferupload service..."
    systemctl stop transferupload
else
    # Service is not active, no need to stop it
    echo "transferupload service is already stopped. Skipping..."
fi

# Remove systemd service
echo "Removing transferupload service..."
systemctl disable transferupload
rm /lib/systemd/system/transferupload.service

# Remove log files and log file paths
echo "Removing log files..."
rm /var/log/transferupload/log.log
rm /var/log/transferupload/error.log
rmdir /var/log/transferupload

# Remove configuration file and configuration file path
echo "Removing configuration file..."
rm /etc/transferupload/.env
rmdir /etc/transferupload

# Remove ExifTool configuration file:
echo "Removing ExifTool's configuration file..."
rm $HOME/.ExifTool_config

echo "Uninstallation completed."