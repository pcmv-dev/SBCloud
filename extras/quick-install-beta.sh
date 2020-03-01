#!/bin/bash
# WARNING! SCRIPT IS EXPERIMENTAL!
# Autosetup of "CloudStorage"

# Install needed packages
sudo apt update && sudo apt install git p7zip-full fuse -y

# Install Rclone
if [ -f "/usr/bin/rclone" ]; then
    echo "Rclone already installed..."
else
    curl https://rclone.org/install.sh | sudo bash -s beta >/dev/null
fi

# Install Mergerfs
ID="$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')"
VERSION_CODENAME="$(grep -oP '(?<=^VERSION_CODENAME=).+' /etc/os-release | tr -d '"')"
mergerfs="/tmp/mergerfs.deb"
mergerfs_latest="$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/trapexit/mergerfs/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")"
url="https://github.com/trapexit/mergerfs/releases/download/$mergerfs_latest/mergerfs_$mergerfs_latest.$ID-${VERSION_CODENAME}_amd64.deb"
if [ -f "/usr/bin/mergerfs" ]; then
    echo
    echo "Mergerfs already installed..."
    echo -n "Install/Update anyway (y/n)? "
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        sudo rm -rf /usr/bin/mergerfs
        curl -fsSL $url -o $mergerfs
        sudo chmod +x $mergerfs
        sudo dpkg -i $mergerfs
    fi
else
    curl -fsSL $url -o $mergerfs
    sudo chmod +x $mergerfs
    sudo dpkg -i $mergerfs
fi
sudo rm $mergerfs >/dev/null 2>&1

# Install Docker
if [ -x "$(command -v docker)" ]; then
    echo
    echo "Docker already installed..."
    echo -n "Run anyway (y/n)? "
    read docker
    if [ "$docker" != "${docker#[Yy]}" ]; then
        sudo rm -f /mnt/user/cloudstorage/install-scripts/install-docker.sh
        sudo curl -fsSL https://get.docker.com -o /mnt/user/cloudstorage/install-scripts/install-docker.sh
        sh /mnt/user/cloudstorage/install-scripts/install-docker.sh
    fi
else
    mkdir -p /mnt/user/cloudstorage/install-scripts
    sudo curl -fsSL https://get.docker.com -o /mnt/user/cloudstorage/install-scripts/install-docker.sh
    sudo sh /mnt/user/cloudstorage/install-scripts/install-docker.sh
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

# Install Rclone Scripts and create directories
mkdir -p /mnt/user/appdata && mkdir -p /mnt/user/logs
PATH="/mnt/user/cloudstorage/rclone"
if [ -f "$PATH/.update" ]; then
    echo
    echo "Rclone scripts already installed"
    echo -n "Download and replace current scripts (y/n)? "
    read rclonescripts
    if [ "$rclonescripts" != "${rclonescripts#[Yy]}" ]; then
        sudo rm -f $PATH/rclone-mount.sh && sudo rm -f $PATH/rclone-unmount.sh && sudo rm -f $PATH/rclone-upload.sh
        sudo curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-mount.sh -o $PATH/rclone-mount.sh
        sudo curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-unmount.sh -o $PATH/rclone-unmount.sh
        sudo curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-upload.sh -o $PATH/rclone-upload.sh
    else
        exit
    fi
else
    sudo touch $PATH/.update
    sudo curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-mount.sh -o $PATH/rclone-mount.sh
    sudo curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-unmount.sh -o $PATH/rclone-unmount.sh
    sudo curl -fsSL https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/rclone/rclone-upload.sh -o $PATH/rclone-upload.sh
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
echo "1.) Run 'sudo usermod -aG docker USER' to run docker without root, change 'USER' to your own"
echo "2.) Run 'sudo chmod -R +x /mnt/user && sudo chown -R USER:USER /mnt/user', change 'USER' to your own"
echo "3.) Relog"
exit
