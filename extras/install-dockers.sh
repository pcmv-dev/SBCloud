#!/bin/bash

# Author: SenpaiBox
# URL: https://github.com/SenpaiBox/CloudStorage
# Description: Installs Portainer,Watchtower,Watcher,Sonarr,Nzbget,Syncthing
# These are lightweight containers perfect for low powered machines.
# You must configure each container with your desired paths and settings.
# The script can also backup container appdata, all containers will be stopped and
# restarted when finished. 7zip must be installed for backups.

BACKUP_DIR="/mnt/backup" # Location of Docker Backups
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1] Install Dockers
[2] Backup Dockers appdata

[3] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
read -p "Type a Number | Press [ENTER]: " answer </dev/tty
if [ "$answer" == "1" ]; then
    echo "Continue with install.."
elif [ "$answer" == "2" ]; then
    sleep 2
    echo "Backup Dockers appdata..."
    docker stop $(docker ps -a -q) &&
    mkdir -p $BACKUP_DIR 2>/dev/null
    7z a -t7z $BACKUP_DIR/appdata.7z /mnt/appdata -xr'!rclonedata' && docker start $(docker ps -a -q -f status=exited)
    currentuser="$(who | awk '{print $1}')"
    chown -R $currentuser:$currentuser $BACKUP_DIR 2>/dev/null
    echo "Backup Complete..."
    exit
elif [ "$answer" == "3" ]; then
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
else
    echo "Docker is not installed, please install first..."
    exit
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Portainer...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
portainercheck="portainer"
if  docker ps -a --format '{{.Names}}' | grep -Eq "^${portainercheck}\$"; then
    echo
    echo "Portainer already installed..."
else
    echo "Installing Portainer..."
    docker volume create portainer_data
    docker run -d \
    -p 8000:8000 -p 9000:9000 \
    --name=portainer --restart=always --network=proxynet \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Watchtower...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
watchtowercheck="watchtower"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${watchtowercheck}\$"; then
    echo
    echo "Watchtower already installed..."
else
    echo "Installing Watchtower..."
    docker run -d \
    --name watchtower \
    --network=proxynet \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e WATCHTOWER_NOTIFICATIONS=email \
    -e WATCHTOWER_NOTIFICATION_EMAIL_FROM="from@email.com" \
    -e WATCHTOWER_NOTIFICATION_EMAIL_TO="to@email.com" \
    -e WATCHTOWER_NOTIFICATION_EMAIL_SERVER="smtp.gmail.com" \
    -e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_USER="user" \
    -e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PASSWORD="pass" \
    -e WATCHTOWER_NOTIFICATION_EMAIL_DELAY=2 \
    containrrr/watchtower \
    --cleanup --schedule "0 */6 * * *"
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Letsencrypt - Reverse Proxy...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
letsencryptcheck="letsencrypt"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${letsencryptcheck}\$"; then
    echo
    echo "Letsencrypt - Reverse Proxy already installed..."
else
    echo "Installing Letsencrypt - Reverse Proxy..."
    docker create \
    --name=letsencrypt \
    --network=proxynet \
    --cap-add=NET_ADMIN \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Europe/London \
    -e URL=yourdomain.url \
    -e SUBDOMAINS=www, \
    -e VALIDATION=http \
    -e DNSPLUGIN=cloudflare `#optional` \
    -e DUCKDNSTOKEN=<token> `#optional` \
    -e EMAIL=<e-mail> `#optional` \
    -e DHLEVEL=2048 `#optional` \
    -e ONLY_SUBDOMAINS=false `#optional` \
    -e EXTRA_DOMAINS=<extradomains> `#optional` \
    -e STAGING=false `#optional` \
    -p 443:443 \
    -p 80:80 `#optional` \
    -v </path/to/appdata/config>:/config \
    --restart always \
    linuxserver/letsencrypt
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Heimdall...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
heimdallcheck="heimdall"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${heimdallcheck}\$"; then
    echo
    echo "Heimdall already installed..."
else
    echo "Installing Heimdall..."
    docker create \
    --name=heimdall \
    --network=proxynet \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Europe/London \
    -p 81:80 \
    -v /path/to/appdata/config:/config \
    --restart always \
    linuxserver/heimdall
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Sonarr - TV/Anime PVR...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
sonarrcheck="sonarr"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${sonarrcheck}\$"; then
    echo
    echo "Sonarr already installed..."
else
    docker create \
    --name=sonarr \
    --network=proxynet \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Europe/London \
    -p 8989:8989 \
    -v path to data:/config \
    -v path to downloads:/downloads \
    -v path to tv shows:/tv \
    --restart no \
    linuxserver/sonarr:latest
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Watcher3 - Movies PVR...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
watchercheck="watcher"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${watchercheck}\$"; then
    echo
    echo "Watcher3 already installed..."
else
    docker run -d \
    --name=watcher3 \
    --network=proxynet \
    -v /path/to/config/:/config \
    -v /path/to/downloads/:/downloads \
    -v /path/to/movies/:/movies \
    -e UMASK_SET=022 \
    -e APP_GID=1000 -e APP_UID=1000 \
    -p 9090:9090 \
    --restart no \
    barbequesauce/watcher3
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install NzbGet - NZB Usenet Downloader...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
nzbgetcheck="nzbget"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${nzbgetcheck}\$"; then
    echo
    echo "NzbGet already installed..."
else
    docker create \
    --name=nzbget \
    --network=proxynet \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Europe/London \
    -p 6789:6789 \
    -v path to data:/config \
    -v path/to/downloads:/downloads \
    --restart unless-stopped \
    linuxserver/nzbget
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Syncthing - File Syncing...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
syncthingcheck="syncthing"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${syncthingcheck}\$"; then
    echo
    echo "Syncthing already installed..."
else
    docker create \
    --name=syncthing \
    --network=proxynet \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Europe/London \
    -e UMASK_SET=022 \
    -p 8384:8384 \
    -p 22000:22000 \
    -p 21027:21027/udp \
    -v /path/to/appdata/config:/config \
    -v /path/to/data1:/data1 \
    -v /path/to/data2:/data2 \
    --restart unless-stopped \
    linuxserver/syncthing
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DOCKERS INSTALL COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
exit