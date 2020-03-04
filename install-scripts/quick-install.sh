#!/bin/bash
# WARNING! SCRIPT IS EXPERIMENTAL!
# Autosetup of "CloudStorage"

# Install needed packages
apt update && apt install git p7zip-full fuse -y

# Install Rclone
if [ -x "$(command -v rclone)" ]; then
    echo "Rclone already installed..."
else
    curl https://rclone.org/install.sh |  bash -s beta
fi

# Install Mergerfs
id="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
version_codename="$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release | tr -d '"')"
mergerfs="/tmp/mergerfs.deb"
mergerfs_latest="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/trapexit/mergerfs/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
url="https://github.com/trapexit/mergerfs/releases/download/$mergerfs_latest/mergerfs_$mergerfs_latest.$id-${version_codename}_amd64.deb"
if [ -x "$(command -v mergerfs)" ]; then
    echo
    echo "Mergerfs already installed..."
    echo -n "Install/Update anyway (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf /usr/bin/mergerfs
        curl -fsSL $url -o $mergerfs
        sudo chmod +x $mergerfs
        sudo dpkg -i $mergerfs
        sudo chown root /usr/bin/mergerfs
        sudo chmod u+s /usr/bin/mergerfs
    fi
else
    curl -fsSL $url -o $mergerfs
    sudo chmod +x $mergerfs
    sudo dpkg -i $mergerfs
    sudo chown root /usr/bin/mergerfs
    sudo chmod u+s /usr/bin/mergerfs
fi
rm $mergerfs >/dev/null 2>&1

# Install Docker
if [ -x "$(command -v docker)" ]; then
    echo
    echo "Docker already installed..."
    echo -n "Run anyway (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -f /mnt/cloudstorage/install-scripts/install-docker.sh
        curl -fsSL https://get.docker.com -o /mnt/cloudstorage/install-scripts/install-docker.sh
        sh /mnt/cloudstorage/install-scripts/install-docker.sh
    fi
else
    mkdir -p /mnt/cloudstorage/install-scripts
    curl -fsSL https://get.docker.com -o /mnt/cloudstorage/install-scripts/install-docker.sh
    sh /mnt/cloudstorage/install-scripts/install-docker.sh >/dev/null
fi

# Install docker-compose
dockercompose="/usr/local/bin/docker-compose"
compose_ver="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/docker/compose/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
compose_url="https://github.com/docker/compose/releases/download/$compose_ver/docker-compose-$(uname -s)-$(uname -m)"
if [ -f "$dockercompose" ]; then
    echo
    echo "docker-compose already installed..."
    echo -n "Install/Update anyway (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf $dockercompose
        curl -L $compose_url -o $dockercompose
        sudo chmod +x $dockercompose
        docker-compose --version
    fi
else
    curl -L $compose_url -o $dockercompose
    sudo chmod +x $dockercompose
fi

# Install Portainer
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

# Install WatchTower
watchtowercheck="watchtower"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${watchtowercheck}\$"; then
    echo
    echo "WatchTower already installed..."
else
    echo "Installing WatchTower..."
    docker run -d \
    --name watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --cleanup --schedule "0 */6 * * *"
fi

# Install Rclone Scripts and create directories
cloudstorage="/mnt/cloudstorage"
rclonescripts="/mnt/cloudstorage/rclone"
installscripts="/mnt/cloudstorage/install-scripts"
extras="/mnt/cloudstorage/extras"
mkdir -p $cloudstorage
mkdir -p $rclonescripts
mkdir -p $installscripts
mkdir -p $extras
if [ -f "$cloudstorage/.update" ]; then
    echo
    echo "CloudStorage scripts already installed"
    echo -n "Overwrite/Update current scripts (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        rm -rf $rclonescripts/* & rm -rf $installscripts/* & rm -rf $extras/*
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/rclone/rclone-mount.sh -o $rclonescripts/rclone-mount
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/rclone/rclone-unmount.sh -o $rclonescripts/rclone-unmount
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/rclone/rclone-upload.sh -o $rclonescripts/rclone-upload
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/install-scripts/quick-install.sh -o $installscripts/quick-install.sh
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/extras/add-to-cron.sh -o $extras/add-to-cron.sh
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/extras/watchtower-notification.sh -o $extras/watchtower-notification.sh
        curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/extras/docker-memory-tweak.sh -o $extras/docker-memory-tweak.sh
        echo "Scripts have been overwritten!"
        echo "You need to reconfigure your Rclone scripts"
        echo "Don't forget to do a 'sudo chmod -R +x /mnt/cloudstorage'"
        exit
    fi
else
    touch $cloudstorage/.update
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/rclone/rclone-mount.sh -o $rclonescripts/rclone-mount
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/rclone/rclone-unmount.sh -o $rclonescripts/rclone-unmount
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/rclone/rclone-upload.sh -o $rclonescripts/rclone-upload
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/install-scripts/quick-install.sh -o $installscripts/quick-install.sh
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/extras/add-to-cron.sh -o $extras/add-to-cron.sh
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/extras/watchtower-notification.sh -o $extras/watchtower-notification.sh
    curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/Development/extras/docker-memory-tweak.sh -o $extras/docker-memory-tweak.sh
    echo "Rclone scripts have been added to Path. You can run them from any directory"
    ln $rclonescripts/rclone-mount /usr/local/bin && ln $rclonescripts/rclone-unmount /usr/local/bin && ln $rclonescripts/rclone-upload /usr/local/bin
fi

# Install complete
echo "================================"
mergerfs -v
echo "================================"
rclone --version
echo "================================"
docker -v
docker-compose --version
echo
echo "Install complete! Now do the following:"
echo "[1] Run 'sudo usermod -aG docker USER' to run docker without root, change 'USER' to your own"
echo "[2] Run 'sudo chmod -R +x /mnt/cloudstorage && sudo chown -R USER:USER /mnt', change 'USER' to your own"
echo "[3] Relog"
exit
