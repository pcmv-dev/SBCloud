#!/bin/bash
# Mergerfs version: 2.28.3
# This script installs mergerfs for "Debian 9 stretch"

url="https://github.com/trapexit/mergerfs/releases/download/2.28.3"
pkg="mergerfs_2.28.3.debian-stretch_amd64.deb"
if [ -f "/usr/bin/mergerfs" ]; then
    printf "Mergerfs already installed..."
    exit
else
    wget -q ~/tmp/$pkg $url/$pkg & dpkg -i ~/tmp/$pkg
fi
find ~/tmp -name $pkg -delete >/dev/null
printf "Mergerfs successfully installed"
mergerfs -v
exit
