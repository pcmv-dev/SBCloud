#!/bin/sh
# This script will install latest version of "Docker-Compose"
if [ -f "/usr/bin/curl" ]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Curl already installed..."
else
    echo "INFO: $(date "+%m/%d/%Y %r") - Installing Curl..."
    sudo apt update && sudo apt install curl -y
fi
if [ -f "/usr/local/bin/docker-compose" ]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Docker-Compose is already Insalled"
    docker-compose --version
    exit 1
else
    COMPOSE_VER=$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/docker/compose/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")
    sudo curl -o /usr/local/bin/docker-compose -L https://github.com/docker/compose/releases/download/$COMPOSE_VER/docker-compose-$(uname -s)-$(uname -m)
    sudo chmod +x /usr/local/bin/docker-compose
    docker-compose --version
    echo "INFO: $(date "+%m/%d/%Y %r") - Docker-Compose successfully installed"
fi
exit
