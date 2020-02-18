#!/bin/bash
# This script will install latest version of "Docker-Compose"
# Run after installing Docker

if [ -f "/usr/local/bin/docker-compose" ]; then
    echo "Docker-Compose is already Insalled"
    docker-compose --version
    exit 1
else
    COMPOSE_VER=$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/docker/compose/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")
    sudo curl -o /usr/local/bin/docker-compose -L https://github.com/docker/compose/releases/download/$COMPOSE_VER/docker-compose-$(uname -s)-$(uname -m)
    sudo chmod +x /usr/local/bin/docker-compose
    printf "\nDocker-Compose successfully installed\n"
    docker-compose --version
fi
exit
