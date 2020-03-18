#!/bin/bash
# Author: SenpaiBox
# URL: https://github.com/SenpaiBox/CloudStorage
# Description: This script Installs/Uninstalls recommended containers, start/stop containers,
# and backup container appdata

if [ `whoami` != root ]; then
    echo "Warning! Please run as sudo/root"
    exit
fi
command -v docker >/dev/null 2>&1
if [ "$?" != "0" ]; then
    echo "Warning! Docker is not installed!"
    exit
fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DOCKER MANAGER v0.02
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INFO: Helps manage core containers
CONTAINERS: Portainer, Ouroboros, Letsencrypt, Heimdall, Sonarr, Radarr, Nzbget
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1] Install Containers
[2] Backup Docker Containers appdata
[3] Start/Stop Containers
[4] Remove All Containers, Networks, Images, Volumes
[5] Remove Specific Container
[6] Docker Remove Unused Networks, Images, Volumes

[7] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
read -p "Type a Number | Press [ENTER]: " answer </dev/tty
if [ "$answer" == "1" ]; then
    echo
    echo "Continue with install.."
    elif [ "$answer" == "2" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STARTING BACKUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    BACKUP_CONTAINERS="$(docker ps | awk '{if(NR>1) print $NF}')"
    APPDATA_DIR="/mnt/appdata"
    BACKUP_DIR="/mnt/backups"
    command -v 7z >/dev/null 2>&1
    if [ "$?" != "0" ]; then
        echo "7zip not detected, installing please wait..."
        apt update && apt install p7zip-full -y
    fi
    echo "Backing up appdata for containers:"
    echo "${BACKUP_CONTAINERS}"
    sleep 2
    echo "Stopping containers..."
    docker stop $(docker ps -a -q) &&
    mkdir -p $BACKUP_DIR 2>/dev/null
    7z a -t7z $BACKUP_DIR/appdata.7z $APPDATA_DIR -xr'!rclonedata' &&
    echo "Restarting containers..."
    docker start $(docker ps -a -q -f status=exited)
    currentuser="$(who | awk '{print $1}')"
    chown -R $currentuser:$currentuser $BACKUP_DIR 2>/dev/null
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BACKUP COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    exit
    elif [ "$answer" == "3" ]; then
    startedcontainers="$(docker ps -a | awk '{if(NR>1) print $NF}')"
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
START/STOP CONTAINERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CURRENTLY RUNNING CONTAINERS:
${startedcontainers}

[1] Start All Containers
[2] Stop All Containers

[3] Cancel
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    read -p "Type a Number | Press [ENTER]: " control </dev/tty
    if [ "$control" == "1" ]; then
        echo
        echo 1>&2 "Starting all containers, please wait..."
        docker start $(docker ps -a -q -f status=created) >/dev/null 2>&1
        docker start $(docker ps -a -q -f status=exited) >/dev/null 2>&1
        docker ps | awk '{if(NR>1) print $NF}'
        sleep 1
        echo 1>&2 "All stopped containers have been restarted"
        exit
        elif [ "$control" == "2" ]; then
        echo 1>&2 "Stopping containers, please wait..."
        docker ps | awk '{if(NR>1) print $NF}'
        docker stop $(docker ps -a -q) >/dev/null 2>&1
        sleep 1
        echo 1>&2 "All containers have been stopped"
        exit
        elif [ "$control" == "3" ]; then
        exit
    fi
    elif [ "$answer" == "4" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REMOVE CONTAINERS, NETWORKS, IMAGES, BUILD CACHE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    sleep 1
    docker stop $(docker ps -a -q) >/dev/null 2>&1
    echo "INFO: All containers have been stopped"
    docker system prune -a
    echo
    echo "REMOVE VOLUMES"
    docker volume prune
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
UNINSTALL COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    exit
    elif [ "$answer" == "5" ]; then
    validcontainers="$(docker ps -a | awk '{if(NR>1) print $NF}')"
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REMOVE SPECIFIC CONTAINER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${validcontainers}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    echo
    read -p "Type the container you wish to uninstall: " dockercontainer </dev/tty
        echo "Stopping:"
        sleep 1
        docker stop "$dockercontainer" || true
        echo "Removing:"
        sleep 1
        docker rm -v "$dockercontainer" || true
        echo "Removing unused images"
        sleep 1
        docker image prune -a -f >/dev/null 2>&1
        exit
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
UNINSTALL COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    exit
    elif [ "$answer" == "6" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DOCKER SYSTEM PRUNE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    echo "REMOVE CONTAINERS, NETWORKS, IMAGES, CACHE"
    docker system prune
    echo
    echo "REMOVE VOLUMES"
    docker volume prune
    echo
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DOCKER SYSTEM PRUNE COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    exit
    elif [ "$answer" == "7" ]; then
    exit
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Checking if Docker is installed...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
if [ -x "$(command -v docker)" ]; then
    echo
    echo "Docker is installed, proceeding..."
    docker network inspect proxynet >/dev/null 2>&1 || docker network create --attachable proxynet
else
    echo "Docker is not installed, please install first..."
    exit
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Checking if Portainer is installed...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 1
curl -fsSL https://raw.githubusercontent.com/Qballjos/portainer_templates/master/Template/template.json -o /mnt/appdata/portainer/templates.json 2>/dev/null
portainercheck="portainer"
if  docker ps -a --format '{{.Names}}' | grep -Eq "^${portainercheck}\$"; then
    echo
    echo "Portainer already installed..."
else
    echo
    echo "Installing Portainer..."
    docker volume create portainer_data
    docker run -d \
    -p 8000:8000 -p 9000:9000 \
    --name=portainer --restart=unless-stopped --network=proxynet \
    -v /mnt/appdata/portainer/templates.json:/templates.json \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Ouroboros...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 1
ouroboroscheck="ouroboros"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${ouroboroscheck}\$"; then
    echo
    echo "ouroboros already installed..."
else
    echo
    echo "Installing Ouroboros..."
    docker run -d \
    --name=ouroboros \
    --restart=unless-stopped \
    -e TZ=America/Chicago \
    -e LOG_LEVEL=info \
    -e NOTIFIERS="" \
    -e CRON="0 */6 * * *" \
    -e CLEANUP=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /etc/localtime:/etc/localtime:ro \
    pyouroboros/ouroboros
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Letsencrypt - Reverse Proxy...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 1
letsencryptcheck="letsencrypt"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${letsencryptcheck}\$"; then
    echo
    echo "Letsencrypt - Reverse Proxy already installed..."
else
    echo
    echo "Installing Letsencrypt - Reverse Proxy..."
    docker create \
    --name=letsencrypt \
    --network=proxynet \
    --cap-add=NET_ADMIN \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Chicago \
    -e URL=temp.domain.com \
    -e SUBDOMAINS=wildcard \
    -e VALIDATION=dns \
    -e DNSPLUGIN=cloudflare `#optional` \
    -e DHLEVEL=2048 `#optional` \
    -e ONLY_SUBDOMAINS=false `#optional` \
    -p 443:443 \
    -p 80:80 `#optional` \
    -v /mnt/appdata/letsencrypt:/config \
    --restart unless-stopped \
    linuxserver/letsencrypt:latest
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Heimdall...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 1
heimdallcheck="heimdall"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${heimdallcheck}\$"; then
    echo
    echo "Heimdall already installed..."
else
    echo
    echo "Installing Heimdall..."
    docker create \
    --name=heimdall \
    --network=proxynet \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Chicago \
    -p 81:80 \
    -v /mnt/appdata/heimdall:/config \
    --restart unless-stopped \
    linuxserver/heimdall:latest
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Sonarr - TV/Anime PVR...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 1
sonarrcheck="sonarr"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${sonarrcheck}\$"; then
    echo
    echo "Sonarr already installed..."
else
    echo
    echo "Installing Sonarr..."
    docker create \
    --name=sonarr \
    --network=proxynet \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Chicago \
    -p 8989:8989 \
    -v /mnt/appdata/sonarr:/config \
    -v /mnt:/mnt \
    -v /mnt/medialibrary/tv:/tv \
    -v /mnt/downloads:/downloads \
    --restart no \
    linuxserver/sonarr:latest
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Radarr - Movies PVR...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 1
radarrcheck="radarr"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${radarrcheck}\$"; then
    echo
    echo "Radarr already installed..."
else
    echo
    echo "Installing Radarr - Movies PVR..."
    docker create \
    --name=radarr \
    --network=proxynet \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Chicago \
    -p 7878:7878 \
    -v /mnt/appdata/radarr:/config \
    -v /mnt:/mnt \
    -v /mnt/medialibrary/movies:/movies \
    -v /mnt/downloads:/downloads \
    --restart no \
    linuxserver/radarr:latest
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install NzbGet - NZB Usenet Downloader...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 1
nzbgetcheck="nzbget"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${nzbgetcheck}\$"; then
    echo
    echo "NzbGet already installed..."
else
    echo
    echo "Installing Nzbget..."
    docker create \
    --name=nzbget \
    --network=proxynet \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/Chicago \
    -p 6789:6789 \
    -v /mnt/appdata/nzbget:/config \
    -v /mnt:/mnt \
    -v /mnt/downloads:/downloads \
    --restart unless-stopped \
    linuxserver/nzbget:latest
fi
extip="$(curl -s ifconfig.me)"
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DOCKERS INSTALL COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
tee <<-EOF
Your External IP: $extip
You can configure installed containers with Portainer:
LOCAL >> http://localhost:9000
EXTERNAL >> http://$extip:9000
EOF
exit