#!/bin/bash

# Install needed packages
apt update && apt install git p7zip-full fuse -y

# Install Rclone
if [ -f "/usr/bin/rclone" ]; then
    echo "Rclone already installed..."
else
    curl https://rclone.org/install.sh |  bash -s beta >/dev/null
fi

# Install Mergerfs
ID="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
VERSION_CODENAME="$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release | tr -d '"')"
mergerfs="/tmp/mergerfs.deb"
mergerfs_latest="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/trapexit/mergerfs/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
url="https://github.com/trapexit/mergerfs/releases/download/$mergerfs_latest/mergerfs_$mergerfs_latest.$ID-${VERSION_CODENAME}_amd64.deb"
if [ -f "/usr/bin/mergerfs" ]; then
    echo
    echo "Mergerfs already installed..."
    echo -n "Install/Update anyway (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf /usr/bin/mergerfs
        curl -fsSL $url -o $mergerfs
        sudo chmod +x $mergerfs
        sudo dpkg -i $mergerfs
    fi
else
    curl -fsSL $url -o $mergerfs
    sudo chmod +x $mergerfs
    sudo dpkg -i $mergerfs
fi
rm $mergerfs >/dev/null 2>&1

# Install complete
echo
which fusermount
which mergerfs
mergerfs -v
echo "================================"
which rclone
rclone --version
echo
echo "Install complete!"
exit