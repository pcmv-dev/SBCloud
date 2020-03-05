#!/bin/bash

########################
#### Unmount Script ####
########################
####  Version 0.05  ####
########################

# CONFIGURE
MEDIA="media" # Local share name NOTE: This is the directory you share to "Radarr,Sonarr,Plex,etc" EX: "/mnt/media"

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

# Advanced Settings, Edit only if you know what you are doing
MEDIAROOT="/mnt" # Your root directory. The directory where you want everything saved to EX: "/mnt/media" "/mnt/appdata"
APPDATA="$MEDIAROOT/appdata/rclonedata/$MEDIA" # Rclone data folder location NOTE: Best not to touch this or map anything here
RCLONEUPLOAD="$APPDATA/rclone_upload" # Staging folder of files to be uploaded
RCLONEMOUNT="$APPDATA/rclone_mount" # Rclone mount folder
MERGERFSMOUNT="$MEDIAROOT/$MEDIA" # Media share location

# Unmount Rclone/Mergerfs mount and remove lock file
echo "==== STARTING UNMOUNT SCRIPT ===="
if [ -f "$APPDATA/mount.lock" ]; then
    echo "$(date "+%d/%m/%Y %T") INFO: Rclone mount detected"
    fusermount -uz $RCLONEMOUNT 2>/dev/null
    fusermount -uz $MERGERFSMOUNT 2>/dev/null
    rm -f $APPDATA/mount.lock 2>/dev/null
else
    echo "$(date "+%d/%m/%Y %T") INFO: Rclone mount exited properly"
fi

# Remove upload lock file
if [ -f "$APPDATA/upload.lock" ]; then
    echo "$(date "+%d/%m/%Y %T") INFO: Rclone upload detected"
    rm -f $APPDATA/upload.lock 2>/dev/null
else
    echo "$(date "+%d/%m/%Y %T") SUCCESS: Rclone upload exited properly"
fi

# Remove empty folders
if [ -n "$(ls -A $MERGERFSMOUNT 2>/dev/null)" ]; then
    echo "$(date "+%d/%m/%Y %T") ERROR: Your Cloud Drive failed to unmount!"
else
    echo "$(date "+%d/%m/%Y %T") INFO: Removing folders in Cloud Drive"
    rmdir $MERGERFSMOUNT 2>/dev/null
fi
if [ -n "$(ls -A $RCLONEMOUNT 2>/dev/null)" ]; then
    echo "$(date "+%d/%m/%Y %T") WARN: Rclone mount is not empty!"
else
    echo "$(date "+%d/%m/%Y %T") INFO: Removing Rclone mount empty folder"
    rmdir $RCLONEMOUNT 2>/dev/null
fi
if [ -n "$(ls -A $RCLONEUPLOAD 2>/dev/null)" ]; then
    echo "$(date "+%d/%m/%Y %T") INFO: There are files pending upload"
else
    echo "$(date "+%d/%m/%Y %T") INFO: Removing Mergerfs local files folder"
    rmdir $RCLONEUPLOAD 2>/dev/null
fi

exit