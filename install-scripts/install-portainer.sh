#!/bin/bash
# This script installs Portainer
# Run this script after installing Docker and Docker-Compose
# Access at "http://yourip:9000"

container="portainer"
if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^${container}\$"; then
    echo "Portainer is installed..."
    exit
else
    echo "Installing Portainer..."
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
fi
exit
