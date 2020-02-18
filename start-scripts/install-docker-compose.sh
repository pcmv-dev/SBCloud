#!/bin/bash
# This script will install latest version of "Docker-Compose"
# Run after installing Docker
command_exists() {
    command -v "$@" > /dev/null 2>&1
}
user="$(id -un 2>/dev/null || true)"
sh_c='sh -c'
if [ "$user" != 'root' ]; then
    if command_exists sudo; then
        sh_c='sudo -E sh -c'
        elif command_exists su; then
        sh_c='su -c'
    else
			cat >&2 <<-'EOF'
			Error: this installer needs the ability to run commands as root.
			We are unable to find either "sudo" or "su" available to make this happen.
			EOF
        exit 1
    fi
fi
if [ -f "/usr/bin/curl" ]; then
    echo "Curl already installed..."
else
    echo "Installing Curl..."
    sudo apt update && apt install curl -y
fi
if [ -f "/usr/local/bin/docker-compose" ]; then
    echo "Docker-Compose is already Insalled"
    docker-compose --version
    exit 1
else
    COMPOSE_VER=$(curl -s -o /dev/null -I -w "%{redirect_url}\n" https://github.com/docker/compose/releases/latest | grep -oP "[0-9]+(\.[0-9]+)+$")
    sudo curl -o /usr/local/bin/docker-compose -L https://github.com/docker/compose/releases/download/$COMPOSE_VER/docker-compose-$(uname -s)-$(uname -m)
    sudo chmod +x /usr/local/bin/docker-compose
    docker-compose --version
    echo "Docker-Compose successfully installed"
fi
exit
