#!/bin/sh
# Install Latest Rclone Beta
if [ -f "/bin/fusermount" ]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Fusermount already installed..."
else
    echo "INFO: $(date "+%m/%d/%Y %r") - Installing Fusermount..."
    sudo apt update && sudo apt install fuse -y
fi
curl https://rclone.org/install.sh | sudo bash -s beta
exit
