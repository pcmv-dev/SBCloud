#!/bin/bash
# Mergerfs version: 2.28.3
# This script installs mergerfs for "Debian 10 buster"

url="https://github.com/trapexit/mergerfs/releases/download/2.28.3/mergerfs_2.28.3.debian-buster_amd64.deb"
mergerfs="/tmp/mergerfs.deb"
if [ -f "/bin/fusermount" ]; then
    printf "Fusermount already installed..."
else
    printf "Installing Fusermount..."
    sudo apt update && sudo apt install fuse -y
fi
if [ -f "/usr/bin/mergerfs" ]; then
    printf "Mergerfs already installed..."
    exit
else
    sudo curl -fsSL $url -o $mergerfs
    sudo chmod +x $mergerfs
    sudo dpkg -i $mergerfs
fi
sudo rm $mergerfs
printf "Mergerfs successfully installed"
mergerfs -v
exit
