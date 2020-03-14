#!/bin/bash
# Author: SenpaiBox
# URL: https://github.com/SenpaiBox/CloudStorage
# Description: Automate uploading to your cloud storage. This uses "Mergerfs" for compatiability with
# Sonarr, Radarr, and streaming to Plex/Emby. Automate uploading from a local or
# remote machine running Ubuntu 18.04 or Debian 9/10.

tee <<-NOTICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSTALLER: CloudStorage v0.05
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER:
I am not responsible for anything that could go wrong.
I am not responsible for any data loss that could potentialy happen.
You agree to use these scripts at your own risk.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTICE
sleep 3

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1] Run Installer
[2] Reinstall - Remove and reset
[3] Uninstall - Remove all

[4] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

cloudstorage="/mnt/cloudstorage"
rclonescripts="/mnt/cloudstorage/rclone"
installscripts="/mnt/cloudstorage/install-scripts"
extras="/mnt/cloudstorage/extras"
localbin="/usr/local/bin"

read -p "Type a Number | Press [ENTER]: " answer </dev/tty
if [ "$answer" == "1" ]; then
    echo "Continue with install.."
    
    elif [ "$answer" == "2" ]; then
    echo "Uninstalling Rclone, Docker-CE, Docker-Compose, and resetting CloudStorage scripts..."
    sleep 2
    apt purge docker-ce -y && apt purge mergerfs -y && apt autoremove -y
    rm -rf $localbin/docker-compose \
    /usr/bin/rclone \
    /mnt/cloudstorage 2>/dev/null
    elif [ "$answer" == "3" ]; then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Uninstall/Remove all...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    read -p "Are you sure you want to Uninstall (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        echo
        echo "Uninstalling Rclone, Docker-CE, Docker-Compose, and CloudStorage scripts..."
        sleep 2
        apt purge docker-ce -y && apt purge mergerfs -y && apt autoremove -y
        rm -rf $localbin/docker-compose /usr/bin/rclone /mnt/cloudstorage /mnt/logs 2>/dev/null
        rm $localbin/rclone-mount $localbin/rclone-unmount $localbin/rclone-upload $localbin/docker-manager $localbin/rclone-cron $localbin/install-cloudstorage 2>/dev/null
        echo "All has been removed except your backups and appdata"
    else
        exit
    fi
    elif [ "$answer" == "4" ]; then
    exit
fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Installing prerequesites...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
apt update && apt install curl git p7zip-full fuse man -y

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Installing Rclone...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
if [ -x "$(command -v rclone)" ]; then
    echo
    echo "Rclone already installed..."
else
    curl https://rclone.org/install.sh |  bash -s beta
fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install MergerFS...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
id="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
version_codename="$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release | tr -d '"')"
mergerfs="/tmp/mergerfs.deb"
mergerfs_latest="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/trapexit/mergerfs/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
url="https://github.com/trapexit/mergerfs/releases/download/${mergerfs_latest}/mergerfs_${mergerfs_latest}.${id}-${version_codename}_amd64.deb"
if [ -x "$(command -v mergerfs)" ]; then
    echo
    echo "Mergerfs already installed..."
    read -p "Install/Update anyway (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf /usr/bin/mergerfs
        curl -fsSL $url -o $mergerfs
        chmod +x $mergerfs
        dpkg -i $mergerfs
        chown root /usr/bin/mergerfs
        chmod u+s /usr/bin/mergerfs
    fi
else
    curl -fsSL $url -o $mergerfs
    chmod +x $mergerfs
    dpkg -i $mergerfs
    chown root /usr/bin/mergerfs
    chmod u+s /usr/bin/mergerfs
fi
rm $mergerfs 2>/dev/null
find="$(cat /etc/fuse.conf | grep -c "#user_allow_other")"
if [ $find != 0 ]; then
    echo "Modifiying /etc/fuse.conf to user_allow_other"
    sed -i "s/#user_allow_other/user_allow_other/g" /etc/fuse.conf
else
    echo "Fuse is already set to user_allow_other"
fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install Docker-CE...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
install_docker="/tmp/install-docker.sh"
if [ -x "$(command -v docker)" ]; then
    echo
    echo "Docker already installed..."
    read -p "Run anyway (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        curl -fsSL https://get.docker.com -o $install_docker
        chmod +x $install_docker
        sh $install_docker
    fi
else
    curl -fsSL https://get.docker.com -o $install_docker
    sh $install_docker >/dev/null 2>&1
    echo "Docker successfully installed..."
    docker -v
fi
rm $install_docker 2>/dev/null

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Install docker-compose...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
dockercompose="$localbin/docker-compose"
compose_ver="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/docker/compose/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
compose_url="https://github.com/docker/compose/releases/download/${compose_ver}/docker-compose-$(uname -s)-$(uname -m)"
if [ -f "$dockercompose" ]; then
    echo
    echo "docker-compose already installed..."
    read -p "Install/Update anyway (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf $dockercompose
        curl -L $compose_url -o $dockercompose
        chmod +x $dockercompose
        docker-compose --version
    fi
else
    curl -L $compose_url -o $dockercompose
    chmod +x $dockercompose
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
    --name=portainer --restart=always \
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
    echo "WatchTower already installed..."
else
    echo "Installing WatchTower..."
    docker run -d \
    --name=watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --cleanup --schedule "0 */6 * * *"
fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Setup CloudStorage...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
github="https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master"
mkdir -p $cloudstorage $rclonescripts $installscripts $extras
if [ -f "$cloudstorage/.update" ]; then
    echo
    echo "CloudStorage scripts already installed"
    read -p "Overwrite/Update current scripts (y/n)? " answer </dev/tty
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm $localbin/rclone-mount $localbin/rclone-unmount $localbin/rclone-upload $localbin/docker-manager $localbin/rclone-cron $localbin/install-cloudstorage 2>/dev/null
        rm -rf $rclonescripts/* $installscripts/* $extras/* 2>/dev/null
        curl -fsSL $github/rclone/rclone-mount.sh -o $rclonescripts/rclone-mount 2>/dev/null
        curl -fsSL $github/rclone/rclone-unmount.sh -o $rclonescripts/rclone-unmount 2>/dev/null
        curl -fsSL $github/rclone/rclone-upload.sh -o $rclonescripts/rclone-upload 2>/dev/null
        curl -fsSL $github/install-scripts/install-cloudstorage.sh -o $installscripts/install-cloudstorage 2>/dev/null
        curl -fsSL $github/extras/add-to-cron.sh -o $extras/rclone-cron 2>/dev/null
        curl -fsSL $github/extras/docker-manager.sh -o $extras/docker-manager 2>/dev/null
        curl -fsSL $github/extras/docker-memory-tweak.sh -o $extras/docker-memory-tweak.sh 2>/dev/null
        echo "Applying hardlinks to rclone-mount, rclone-unmount, rclone-upload..."
        ln $rclonescripts/rclone-mount $rclonescripts/rclone-unmount $rclonescripts/rclone-upload $localbin 2>/dev/null
        echo "Applying hardlinks to docker-manager, rclone-cron"
        ln $extras/docker-manager $extras/rclone-cron $localbin 2>/dev/null
        echo "Applying hardlinks to install-cloudstorage"
        ln $installscripts/install-cloudstorage $localbin 2>/dev/null
        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Scripts have been overwritten!"
        echo "You need to reconfigure rclone-mount, rclone-unmount, and rclone-upload"
    fi
else
    echo
    echo "Downloading and installing Rclone scripts..."
    sleep 2
    touch $cloudstorage/.update
    curl -fsSL $github/rclone/rclone-mount.sh -o $rclonescripts/rclone-mount 2>/dev/null
    curl -fsSL $github/rclone/rclone-unmount.sh -o $rclonescripts/rclone-unmount 2>/dev/null
    curl -fsSL $github/rclone/rclone-upload.sh -o $rclonescripts/rclone-upload 2>/dev/null
    curl -fsSL $github/install-scripts/install.sh -o $installscripts/install.sh 2>/dev/null
    curl -fsSL $github/extras/add-to-cron.sh -o $extras/add-to-cron.sh 2>/dev/null
    curl -fsSL $github/extras/watchtower-notification.sh -o $extras/watchtower-notification.sh 2>/dev/null
    curl -fsSL $github/extras/docker-memory-tweak.sh -o $extras/docker-memory-tweak.sh 2>/dev/null
    echo "Applying hardlinks to rclone-mount, rclone-unmount, rclone-upload..."
    ln $rclonescripts/rclone-mount $rclonescripts/rclone-unmount $rclonescripts/rclone-upload $localbin 2>/dev/null
    echo "Applying hardlinks to docker-manager, rclone-cron"
    ln $extras/docker-manager $extras/rclone-cron $localbin 2>/dev/null
    echo "Applying hardlinks to install-cloudstorage"
    ln $installscripts/install-cloudstorage $localbin 2>/dev/null
fi

# Apply permissions
currentuser="$(who | awk '{print $1}')"
chmod -R 775 /mnt 2>/dev/null
chown -R ${currentuser}:${currentuser} /mnt 2>/dev/null

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSTALL COMPLETE!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
mergerfs -v
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
rclone --version
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
docker -v
docker-compose --version
tee <<-EOF

NOTE: First time install
    To run Docker without root do the following:
    [1] "sudo usermod -aG docker ${currentuser}"
    [2] Relog afterwards

The following have been added to PATH:
rclone-mount - Mount your Cloud Drive
rclone-unmount - Unmount your Cloud Drive
rclone-upload - Upload to your Cloud Drive
rclone-cron - Add Rclone Scripts to Cron Tasks
docker-manager - Backup and Start/Stop containers
install-cloudstorage - Runs this script again

For updates please visit: https://github.com/SenpaiBox/CloudStorage

EOF
exit