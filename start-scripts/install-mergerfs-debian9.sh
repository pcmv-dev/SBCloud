#!/bin/bash
# Mergerfs version: 2.28.3
# This script installs mergerfs for "Debian 9 stretch"

url="https://github.com/trapexit/mergerfs/releases/download/2.28.3"
pkg="mergerfs_2.28.3.pkg-stretch_amd64.deb"
if [ -f "/usr/bin/mergerfs" ]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Mergerfs already installed"
else
    mkdir -p /tmp
    sudo wget -q /tmp/$pkg $url/$pkg
    sudo dpkg -i /tmp/$pkg
    echo "INFO: $(date "+%m/%d/%Y %r") - Mergerfs successfully installed"
    mergerfs -v
    sudo find /tmp -name $pkg -delete >/dev/null
fi
exit