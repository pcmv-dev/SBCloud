#!/bin/bash
# Mergerfs version: 2.28.3
# This script installs mergerfs for "Debian 9 stretch"
# For the latest release or different OS go to: https://github.com/trapexit/mergerfs/releases
# Copy the link to any package that is .deb

url="https://github.com/trapexit/mergerfs/releases/download/2.28.3/mergerfs_2.28.3.debian-stretch_amd64.deb" # Replace this link with latest version or different OS
mergerfs="/tmp/mergerfs.deb"
if [ -f "/bin/fusermount" ]; then
    echo "Fusermount already installed..."
else
    echo "Installing Fusermount..."
    sudo apt update && sudo apt install fuse -y
fi
if [ -f "/usr/bin/mergerfs" ]; then
    echo "Mergerfs already installed..."
    exit
else
    sudo curl -fsSL $url -o $mergerfs
    sudo chmod +x $mergerfs
    sudo dpkg -i $mergerfs
fi
sudo rm $mergerfs
echo "Mergerfs successfully installed"
mergerfs -v
exit
