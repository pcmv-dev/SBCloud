#!/bin/bash
# Installs latest version of "Mergerfs" and its dependency "Fusermount"
# This script installs mergerfs for "Ubuntu, Debian 9/10" NOTE: x64Bit only!
# To view latests releases go to: https://github.com/trapexit/mergerfs/releases

ID="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
VERSION_CODENAME="$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release | tr -d '"')"
mergerfs="/tmp/mergerfs.deb"
mergerfs_latest="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/trapexit/mergerfs/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
url="https://github.com/trapexit/mergerfs/releases/download/$mergerfs_latest/mergerfs_$mergerfs_latest.$ID-${VERSION_CODENAME}_amd64.deb"
if [ -f "/bin/fusermount" ]; then
    echo "Fusermount already installed..."
else
    echo "Installing Fusermount..."
    sudo apt update && sudo apt install fuse -y
fi
if [ -f "/usr/bin/mergerfs" ]; then
    echo "Mergerfs already installed..."
    echo -n "Install/Update anyway (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        sudo rm -rf /usr/bin/mergerfs
        sudo curl -fsSL $url -o $mergerfs
        sudo chmod +x $mergerfs
        sudo dpkg -i $mergerfs
    else
        exit
    fi
else
    sudo curl -fsSL $url -o $mergerfs
    sudo chmod +x $mergerfs
    sudo dpkg -i $mergerfs
fi
sudo rm $mergerfs
echo "Mergerfs successfully installed"
mergerfs -v
exit
