#!/bin/bash

######################
#### Mount Script ####
######################
#### Version 0.05 ####
######################

# CONFIGURE
REMOTE="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
MEDIA="media" # Local share name NOTE: The name you want to give your share mount
MEDIAROOT="/mnt" # Local share directory
USERID="1000" # Your user ID
GROUPID="1000" # Your group ID

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

# Create variables
APPDATA="/mnt/appdata/rclonedata/$MEDIA" # Rclone data folder location NOTE: Best not to touch this or map anything here
RCLONEUPLOAD="$APPDATA/rclone_upload" # Staging folder of files to be uploaded
RCLONEMOUNT="$APPDATA/rclone_mount" # Rclone mount folder
MERGERFSMOUNT="$MEDIAROOT/$MEDIA" # Media share location
RCLONECONF="~/.config/rclone/rclone.conf" # Rclone config file location
LOCKFILE="$APPDATA/mount.lock" # Rclone mount lock file
MERGERFSOPTIONS="rw,async_read=false,use_ino,allow_other,func.getattr=newest,category.action=all,category.create=ff,cache.files=partial,dropcacheonclose=true" # Mergerfs mount options

# Create directories
mkdir -p $APPDATA
mkdir -p $RCLONEUPLOAD
mkdir -p $RCLONEMOUNT
mkdir -p $MERGERFSMOUNT

# Check if script is already running
echo "==== STARTING MOUNT SCRIPT ===="
echo "$(date "+%d.%m.%Y %T") INFO: Checking if script is already running"
if [ -f "$LOCKFILE" ]; then
    echo "SUCCESS: $(date "+%d.%m.%Y %T") - Check Passed! Your Cloud Drive is already mounted"
    exit
else
    touch "$LOCKFILE"
fi

# Check if rclone mount already created
if [ -n "$(ls -A $RCLONEMOUNT)" ]; then
    echo "$(date "+%d.%m.%Y %T") WARN: Rclone is mounted"
else
    echo "$(date "+%d.%m.%Y %T") INFO: Mounting Rclone, please wait..."
    # Rclone mount command and flags
    rclone mount \
    --config $RCLONECONF \
    --uid="$USERID" --gid="$GROUPID" --umask=002 \
    --log-level ERROR \
    --allow-other \
    --dir-cache-time 1000h \
    --buffer-size 64M \
    --vfs-read-chunk-size 128M \
    --vfs-read-chunk-size-limit off \
    --vfs-cache-mode writes \
    $REMOTE: $RCLONEMOUNT &
    
    # Check if mount successful
    echo "$(date "+%d.%m.%Y %T") INFO: Mount in progress please wait..."
    sleep 5
    echo "$(date "+%d.%m.%Y %T") INFO: Proceeding..."
    if [ "$(ls -A $RCLONEMOUNT)" ]; then
        echo "$(date "+%d.%m.%Y %T") SUCCESS: Check Passed! remote mounted"
    else
        echo "$(date "+%d.%m.%Y %T") ERROR: Check Failed! please check your configuration"
        rm -f "$LOCKFILE"
        exit
    fi
fi

# Check media share mount
if [ -n "$(ls -A $MERGERFSMOUNT)" ]; then
    echo "$(date "+%d.%m.%Y %T") SUCCESS: Check Passed! Your Cloud Drive is mounted"
else
    
    # Check if mergerfs is installed
    if command -v mergerfs 2>/dev/null; then
        echo "$(date "+%d.%m.%Y %T") INFO: Mergerfs found, Proceeding..."
    else
        echo "$(date "+%d.%m.%Y %T") ERROR: Please install Mergerfs first"
        fusermount -uz $RCLONEMOUNT
        rm -f $LOCKFILE
        exit
    fi
    
    # Create mergerfs mount
    mergerfs $RCLONEUPLOAD:$RCLONEMOUNT $MERGERFSMOUNT -o $MERGERFSOPTIONS > /dev/null 2>&1
    
    # Check if mergerfs mounted correctly
    if [ -n "$(ls -A $MERGERFSMOUNT)" ]; then
        echo "$(date "+%d.%m.%Y %T") SUCCESS: Check Passed! Your Cloud Drive is mounted"
        echo "==== REMOTE DIRECTORIES ===="
        rclone lsd $REMOTE: --config $RCLONECONF
        echo "============================"
    else
        echo "$(date "+%d.%m.%Y %T") ERROR: Check Failed! Your Cloud Drive failed to mount, please check your configuration"
        fusermount -uz $RCLONEMOUNT
        rm -f $LOCKFILE
        echo
        exit
    fi
fi
exit
