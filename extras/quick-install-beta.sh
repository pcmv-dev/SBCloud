#!/bin/bash
# WARNING! SCRIPT IS EXPERIMENTAL!
# Autosetup of "CloudStorage"

# Install needed packages
sudo apt update && sudo apt install git p7zip-full fuse -y >/dev/null

# Install Rclone
if [ -f "/usr/bin/rclone" ]; then
    echo "Rclone already installed..."
else
    curl https://rclone.org/install.sh | sudo bash -s beta
fi

# Install Mergerfs
ID="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
VERSION_CODENAME="$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release | tr -d '"')"
mergerfs="/tmp/mergerfs.deb"
mergerfs_latest="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/trapexit/mergerfs/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
url="https://github.com/trapexit/mergerfs/releases/download/$mergerfs_latest/mergerfs_$mergerfs_latest.$ID-${VERSION_CODENAME}_amd64.deb"
if [ -f "/usr/bin/mergerfs" ]; then
    echo "Mergerfs already installed..."
    echo -n "Install/Update anyway (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        sudo rm -rf /usr/bin/mergerfs
        sudo curl -fsSL $url -o $mergerfs
        sudo chmod +x $mergerfs
        sudo dpkg -i $mergerfs
    fi
else
    sudo curl -fsSL $url -o $mergerfs
    sudo chmod +x $mergerfs
    sudo dpkg -i $mergerfs
fi
sudo rm $mergerfs >/dev/null 2>&1

# Install Docker
if [ -x "$(command -v docker)" ]; then
    echo "Docker already installed..."
    echo -n "Run anyway (y/n)? "
    read docker
    if [ "$docker" != "${docker#[Yy]}" ]; then
        sudo rm -f /mnt/user/cloudstorage/install-scripts/install-docker.sh
        curl -fsSL https://get.docker.com -o /mnt/user/cloudstorage/install-scripts/install-docker.sh
        sh /mnt/user/cloudstorage/install-scripts/install-docker.sh
    fi
else
    mkdir -p /mnt/user/cloudstorage/install-scripts
    curl -fsSL https://get.docker.com -o /mnt/user/cloudstorage/install-scripts/install-docker.sh
    sh /mnt/user/cloudstorage/install-scripts/install-docker.sh
fi
-t 5
clear

# Install docker-compose
dockercompose="/usr/local/bin/docker-compose"
compose_ver="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/docker/compose/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
compose_url="https://github.com/docker/compose/releases/download/$compose_ver/docker-compose-$(uname -s)-$(uname -m)"
if [ -f "$dockercompose" ]; then
    echo "docker-compose is installed..."
    echo -n "Install/Update anyway (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        sudo rm -rf $dockercompose
        sudo curl -fsSL $compose_url -o $dockercompose
        sudo chmod +x $dockercompose
    fi
else
    sudo curl -fsSL $compose_url -o $dockercompose
    sudo chmod +x $dockercompose
fi

# Install Portainer
container="portainer"
if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^${container}\$"; then
    echo "Portainer already installed..."
else
    echo "Installing Portainer..."
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
fi

# Install Rclone Scripts
mkdir -p /mnt/user/cloudstorage/rclone
if [ -f "/mnt/user/cloudstorage" ]; then
    echo "Rclone scripts already installed"
    echo -n "Download and replace current scripts (y/n)?"
    read rclonescripts
    if [ "$rclonescripts" != "${rclonescripts#[Yy]}" ]; then
        sudo rm -rf /mnt/user/cloudstorage/rclone
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-mount.sh -o /mnt/user/cloudstorage/rclone/rclone-mount.sh
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-unmount.sh -o /mnt/user/cloudstorage/rclone/rclone-unmount.sh
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-upload.sh -o /mnt/user/cloudstorage/rclone/rclone-upload.sh
        sudo chmod -R +x /mnt/user/cloudstorage/rclone
    else
        exit
    fi
else
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-mount.sh -o /mnt/user/cloudstorage/rclone/rclone-mount.sh
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-unmount.sh -o /mnt/user/cloudstorage/rclone/rclone-unmount.sh
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-upload.sh -o /mnt/user/cloudstorage/rclone/rclone-upload.sh
    sudo chmod -R +x /mnt/user/cloudstorage/rclone
fi

# Create directories and set permissions
mkdir -p /mnt/user & mkdir -p /mnt/user/appdata & mkdir -p /mnt/user/logs
sudo chmod -R +x /mnt/user

# Install complete
echo "================================"
echo "Rclone successfully installed..."
echo "Mergerfs successfully installed..."
echo "Docker successfully installed..."
echo "docker-compose successfully installed..."
echo "================================"
mergerfs -v
echo "================================"
rclone --version
echo "================================"
docker-compose --version
echo "Run 'sudo usermod -aG docker USER' to run docker without root, then relog"
echo "Install complete! Now just setup your Rclone Config file and Cronjob!"
exit