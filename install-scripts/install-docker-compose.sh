#!/bin/bash
# This script will install latest version of "Docker-Compose"
# Run after installing Docker

dockercompose="/usr/local/bin/docker-compose"
compose_ver="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/docker/compose/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
compose_url="https://github.com/docker/compose/releases/download/$compose_ver/docker-compose-$(uname -s)-$(uname -m)"
if [ -f "$dockercompose" ]; then
    echo "Docker-Compose is already Insalled"
    docker-compose --version
    exit 1
else
    sudo curl -fsSL $compose_url -o $dockercompose
    sudo chmod +x $dockercompose
    echo "Docker-Compose successfully installed"
    docker-compose --version
fi
exit
