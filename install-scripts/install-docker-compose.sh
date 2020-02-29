#!/bin/bash
# This script will install latest version of "Docker-Compose"
# Run after installing Docker

dockercompose="/usr/local/bin/docker-compose"
compose_ver="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/docker/compose/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
compose_url="https://github.com/docker/compose/releases/download/$compose_ver/docker-compose-$(uname -s)-$(uname -m)"
if [ -f "$dockercompose" ]; then
    echo "docker-compose is installed..."
    echo -n "Install/Update anyway (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        sudo rm -rf $dockercompose
        sudo curl -fsSL $compose_url -o $dockercompose
        sudo chmod +x $dockercompose
        echo "docker-compose successfully installed"
        docker-compose --version
    else
        exit
    fi
else
    sudo curl -fsSL $compose_url -o $dockercompose
    sudo chmod +x $dockercompose
    echo "docker-compose successfully installed"
    docker-compose --version
fi
exit
