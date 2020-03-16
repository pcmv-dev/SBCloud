#!/bin/bash
# Author: SenpaiBox
# URL: https://github.com/SenpaiBox/CloudStorage
# Description: This script backups container appdata or stop/start all containers

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
[1] Backup Docker Containers appdata
[2] Stop all Containers
[3] Start all Containers

[4] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
read -p "Type a Number | Press [ENTER]: " ANSWER </dev/tty

BACKUP_CONTAINERS="$(docker ps | awk '{if(NR>1) print $NF}')"
APPDATA_DIR="/mnt/appdata" # Location of container appdata
BACKUP_DIR="/mnt/backups" # Location of backup directory
if [ "$ANSWER" == "1" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting backup...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
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
elif [ "$ANSWER" == "2" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stopping all containers...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    docker ps | awk '{if(NR>1) print $NF}'
    docker stop $(docker ps -a -q) >/dev/null 2>&1
    sleep 3
    echo 1>&2 "All containers have been stopped"
    exit
    elif [ "$ANSWER" == "3" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting all containers...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    echo 1>&2 "Starting all stopped containers..."
    docker start $(docker ps -a -q -f status=created) >/dev/null 2>&1
    docker start $(docker ps -a -q -f status=exited) >/dev/null 2>&1
    docker ps | awk '{if(NR>1) print $NF}'
    sleep 3
    echo 1>&2 "All stopped containers have been restarted"
    exit
elif [ "$ANSWER" == "4" ]; then
    exit
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BACKUP COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
exit