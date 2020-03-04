#!/bin/bash
# Checks if Fusermount/Rclone are installed

if [ -x "$(command -v fusermount)" ]; then
    echo "Fusermount already installed..."
    fusermount -V
else
    echo "Installing Fusermount..."
    sudo apt update && sudo apt install fuse -y
fi
if [ -x "$(command -v rclone)" ]; then
    echo "Rclone already installed..."
    rclone --version
else
    echo "Installing Rclone..."
    curl https://rclone.org/install.sh | sudo bash -s beta
fi
exit
