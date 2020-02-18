#!/bin/bash
# Mergerfs version: 2.28.3
# This script installs mergerfs for "Debian 9 stretch"

url="https://github.com/trapexit/mergerfs/releases/download/2.28.3"
pkg="mergerfs_2.28.3.pkg-stretch_amd64.deb"
if [ -f "/usr/bin/mergerfs" ]; then
    printf "\nMergerfs already installed"
else
    sudo wget -q /tmp/$pkg $url/$pkg
    sudo dpkg -i /tmp/$pkg
    printf "\nMergerfs successfully installed"
    mergerfs -v
    sudo find /tmp -name $pkg -delete >/dev/null
fi
exit