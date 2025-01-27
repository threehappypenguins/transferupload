#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo."
  exit 1
fi

# Get the username of the user who invoked sudo
sudo_user="$SUDO_USER"

if [ -f ./.env ] && [ -f ./transferupload.service ]; then
    # Get the home directory of the sudo user
    HOME=$(eval echo ~$sudo_user)

    # Check if the scripts are executable before running chmod
    if [ -x $HOME/transferupload/src/run.sh ] && \
       [ -x $HOME/transferupload/src/main.sh ] && \
       [ -x $HOME/transferupload/src/metadata.sh ] && \
       [ -x $HOME/transferupload/src/uploader.sh ] && \
       [ -x $HOME/transferupload/src/mailer.sh ] && \
       [ -x $HOME/transferupload/src/setup_json.sh ] && \
       [ -x $HOME/transferupload/src/uninstall.sh ]; then
        echo "Scripts are already executable. Skipping..."
    else
        echo "Making scripts executable..."
        chmod +x $HOME/transferupload/src/run.sh \
        $HOME/transferupload/src/main.sh \
        $HOME/transferupload/src/metadata.sh \
        $HOME/transferupload/src/uploader.sh \
        $HOME/transferupload/src/mailer.sh \
        $HOME/transferupload/src/setup_json.sh \
        $HOME/transferupload/uninstall.sh
    fi

    # Check if configuration folder exists
    if [ ! -d /etc/transferupload ]; then
        echo "Creating configuration folder..."
        mkdir -p /etc/transferupload
    fi ; \

    # Copy configuration file
    echo "Copying the configuration file..."
    cp ./.env /etc/transferupload/.env ; \

    # Check if log folder exists
    if [ ! -d /var/log/transferupload ]; then
        echo "Creating log folder..."
        mkdir -p /var/log/transferupload
    fi ; \

    # Check if STDOUT log file exists
    LOG_FILE="/var/log/transferupload/log.log"
    if [ ! -f $LOG_FILE ]; then
        echo "Creating STDOUT log file..."
        touch $LOG_FILE
    fi

    # Check if STDERR log file exists
    ERROR_FILE="/var/log/transferupload/error.log"
    if [ ! -f $ERROR_FILE ]; then
        echo "Creating STDERR log file..."
        touch $ERROR_FILE
    fi

    # Copy systemd file
    home_systemdfile=./transferupload.service
    systemdfile=/lib/systemd/system/transferupload.service
    echo "Copying the systemd file..."
    cp $home_systemdfile $systemdfile ; \

    # Reloading systemd, enable the service
    sudo systemctl daemon-reload
    sudo systemctl enable transferupload
    
    # Checking if the service is already active
    if sudo systemctl is-active --quiet transferupload; then
        # Service is active, restart it
        echo "Restarting transferupload service..."
        sudo systemctl restart transferupload
    else
    # Service is not active, start it
        echo "Starting transferupload service..."
        sudo systemctl start transferupload
    fi

    # Check if the ExifTool config file already exists
    if [ ! -f "$HOME/.ExifTool_config" ]; then
        # Create ExifTool's large file support config file
        cat <<-EOF > "$HOME/.ExifTool_config"
%Image::ExifTool::UserDefined::Options = (
    LargeFileSupport => 1,
);
EOF
        echo "ExifTool's config file created."
    else
        echo "ExifTool's config file already exists. Skipping creation."
    fi

    echo "Done."

else
    if [ ! -f ./.env ]; then
        echo "Error: Configuration file .env not found."
    fi
    if [ ! -f ./transferupload.service ]; then
        echo "Error: Systemd file transferupload.service not found."
    fi
    echo "Exiting installation script." >&2
    exit 1
fi
