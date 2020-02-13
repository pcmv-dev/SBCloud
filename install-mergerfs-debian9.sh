#!/bin/sh

# Install Mergerfs
if [[ -f "/usr/bin/mergerfs" ]]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Mergerfs already installed"
    exit
else
    cd /tmp
    curl https://github.com/trapexit/mergerfs/releases/download/2.28.3/mergerfs_2.28.3.debian-stretch_amd64.deb
    dpkg -i mergerfs_2.28.3.debian-stretch_amd64.deb
    echo "INFO: $(date "+%m/%d/%Y %r") - Mergerfs successfully installed"
    mergerfs -v
    rm mergerfs_2.28.3.debian-stretch_amd64.deb
fi
exit