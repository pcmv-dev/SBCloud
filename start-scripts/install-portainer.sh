#!/bin/bash
# This script installs Portainer on port "9000"
# Run this script after installing Docker and Docker-Compose

if [ ! "$(docker ps -q -f name=portainer)" ]; then
    echo "Portainer is already installed..."
    exit 1
else
    printf "Installing Portainer..."
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
fi
exit
