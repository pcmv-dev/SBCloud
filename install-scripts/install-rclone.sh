#!/bin/bash
# Checks if fusermount is installed, then proceeds to install Rclone

if [ -f "/bin/fusermount" ]; then
    echo "Fusermount already installed..."
else
    echo "Installing Fusermount..."
    sudo apt update && sudo apt install fuse -y
fi
curl https://rclone.org/install.sh | sudo bash -s beta
exit
