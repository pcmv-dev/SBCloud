#!/bin/sh

# Install Mergerfs
url="https://github.com/trapexit/mergerfs/releases/download/2.28.3"
debian="mergerfs_2.28.3.debian-stretch_amd64.deb"
if [ -f "/usr/bin/mergerfs" ]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Mergerfs already installed"
else
    mkdir -p ~/tmp
    sudo wget -q ~/tmp/$debian $url/$debian
    sudo dpkg -i ~/tmp/$debian
    echo "INFO: $(date "+%m/%d/%Y %r") - Mergerfs successfully installed"
    mergerfs -v
    sudo find ~/tmp -name $debaian -delete >/dev/null
fi
exit