#!/bin/sh

# This script will install latest version of "Docker-Compose"
if hash curl 2>/dev/null; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Curl is not installed. Install it first then try again."
    exit 1
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
