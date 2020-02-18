#!/bin/bash
# This script installs Portainer on port "9000"
# Run this script after installing Docker and Docker-Compose

container="portainer"
if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^${container}\$"; then
    printf "Portainer is installed..."
else
    printf "Installing Portainer..."
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
fi
exit
