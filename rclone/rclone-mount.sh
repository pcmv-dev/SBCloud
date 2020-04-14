#!/bin/bash

######################
#### Mount Script ####
######################
#### Version 0.06 ####
######################

# CONFIGURE
REMOTE="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
MEDIA="media" # Local share name NOTE: This is the directory you share to "Radarr,Sonarr,Plex,etc" EX: "/mnt/media"
USERID="1000" # Your user ID
GROUPID="1000" # Your group ID

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

# Make sure we are not running as root
if [[ `whoami` == root ]]; then
    echo "Do not run as sudo/root!"
    exit
fi

# Advanced Settings, Edit only if you know what you are doing
MEDIAROOT="/mnt" # Your root directory. The directory where you want everything saved to EX: "/mnt/media" "/mnt/appdata"
APPDATA="$MEDIAROOT/appdata/rclonedata/$MEDIA" # Rclone appdata folder location
RCLONEUPLOAD="$APPDATA/rclone_upload" # Staging folder of files to be uploaded
RCLONEMOUNT="$APPDATA/rclone_mount" # Rclone mount folder
MERGERFSMOUNT="$MEDIAROOT/$MEDIA" # Media share location
RCLONECONF="$HOME/.config/rclone/rclone.conf" # Rclone config file location
LOCKFILE="$APPDATA/mount.lock" # Rclone mount lock file
MERGERFSOPTIONS="rw,async_read=false,use_ino,allow_other,func.getattr=newest,category.action=all,category.create=ff,cache.files=partial,dropcacheonclose=true" # Mergerfs mount options

# Create directories
mkdir -p $APPDATA $RCLONEUPLOAD $RCLONEMOUNT $MERGERFSMOUNT

# Check if script is already running
echo "==== STARTING MOUNT SCRIPT ===="
echo "$(date "+%d/%m/%Y %T") INFO: Checking if script is already running"
if [[ -f "$LOCKFILE" ]]; then
    echo "SUCCESS: $(date "+%d/%m/%Y %T") - Check Passed! Your Cloud Drive is already mounted"
    exit
else
    touch "$LOCKFILE"
fi

# Check if rclone mount already created
if [[ -n "$(ls -A $RCLONEMOUNT 2>/dev/null)" ]]; then
    echo "$(date "+%d/%m/%Y %T") WARN: Rclone is mounted"
else
    echo "$(date "+%d/%m/%Y %T") INFO: Mounting Rclone, please wait..."
    # Rclone mount command and flags
    rclone mount \
    --config $RCLONECONF \
    --uid="$USERID" --gid="$GROUPID" --umask=002 \
    --log-level ERROR \
    --allow-other \
    --dir-cache-time 1000h \
    --buffer-size 256M \
    --drive-chunk-size 512M \
    --vfs-read-chunk-size 128M \
    --vfs-read-chunk-size-limit off \
    --vfs-cache-mode writes \
    $REMOTE: $RCLONEMOUNT &
    
    # Check if mount successful
    echo "$(date "+%d/%m/%Y %T") INFO: Mount in progress please wait..."
    sleep 5
    echo "$(date "+%d/%m/%Y %T") INFO: Proceeding..."
    if [[ "$(ls -A $RCLONEMOUNT 2>/dev/null)" ]]; then
        echo "$(date "+%d/%m/%Y %T") SUCCESS: Check Passed! remote mounted"
    else
        echo "$(date "+%d/%m/%Y %T") ERROR: Check Failed! please check your configuration"
        rm -f "$LOCKFILE"
        rmdir $APPDATA $RCLONEUPLOAD $RCLONEMOUNT $MERGERFSMOUNT 2>/dev/null
        exit
    fi
fi

# Check media share mount
if [[ -n "$(ls -A $MERGERFSMOUNT 2>/dev/null)" ]]; then
    echo "$(date "+%d/%m/%Y %T") SUCCESS: Check Passed! Your Cloud Drive is mounted"
else
    # Check if mergerfs is installed
    if [[ -x "$(command -v mergerfs)" ]]; then
        echo "$(date "+%d/%m/%Y %T") INFO: Mergerfs found, Proceeding..."
    else
        echo "$(date "+%d/%m/%Y %T") ERROR: Please install Mergerfs first"
        fusermount -uz $RCLONEMOUNT
        rm -f $LOCKFILE
        rmdir $APPDATA $RCLONEUPLOAD $RCLONEMOUNT $MERGERFSMOUNT 2>/dev/null
        exit
    fi
    
    # Create mergerfs mount
    mergerfs $RCLONEUPLOAD:$RCLONEMOUNT $MERGERFSMOUNT -o $MERGERFSOPTIONS
    
    # Check if mergerfs mounted correctly
    if [[ -n "$(ls -A $MERGERFSMOUNT 2>/dev/null)" ]]; then
        echo "$(date "+%d/%m/%Y %T") SUCCESS: Check Passed! Your Cloud Drive is mounted"
        echo "==== REMOTE DIRECTORIES ===="
        rclone lsd $REMOTE: --config $RCLONECONF
        echo "============================"
    else
        echo "$(date "+%d/%m/%Y %T") ERROR: Check Failed! Your Cloud Drive failed to mount, please check your configuration"
        fusermount -uz $RCLONEMOUNT
        rm -f $LOCKFILE
        rmdir $APPDATA $RCLONEUPLOAD $RCLONEMOUNT $MERGERFSMOUNT 2>/dev/null
        echo
        exit
    fi
fi
exit
