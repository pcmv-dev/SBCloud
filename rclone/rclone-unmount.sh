#!/bin/bash

########################
#### Unmount Script ####
########################
####  Version 0.05  ####
########################

#### Configuration ####
MEDIA="media" # Local share name NOTE: The name you want to give your share mount
MEDIAROOT="/mnt" # Local share directory

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

# Create location variables
APPDATA="$MEDIAROOT/appdata/rclonedata/$MEDIA" # Rclone data folder location NOTE: Best not to touch this or map anything here
RCLONEUPLOAD="$APPDATA/rclone_upload" # Staging folder of files to be uploaded
RCLONEMOUNT="$APPDATA/rclone_mount" # Rclone mount folder
MERGERFSMOUNT="$MEDIAROOT/$MEDIA" # Media share location

# Unmount Rclone/Mergerfs mount and remove lock file
echo "==== STARTING UNMOUNT SCRIPT ===="
if [ -f "$APPDATA/mount.lock" ]; then
    echo "$(date "+%d/%m/%Y %T") INFO: Rclone mount detected"
    fusermount -uz $RCLONEMOUNT >/dev/null 2>&1
    fusermount -uz $MERGERFSMOUNT >/dev/null 2>&1
    rm -f $APPDATA/mount.lock >/dev/null 2>&1
else
    echo "$(date "+%d/%m/%Y %T") INFO: Rclone mount exited properly"
fi

# Remove upload lock file
if [ -f "$APPDATA/upload.lock" ]; then
    echo "$(date "+%d/%m/%Y %T") INFO: Rclone upload detected"
    rm -f $APPDATA/upload.lock >/dev/null 2>&1
else
    echo "$(date "+%d/%m/%Y %T") SUCCESS: Rclone upload exited properly"
fi

# Remove empty folders
if [ -n "$(ls -A $MERGERFSMOUNT)" ]; then
    echo "$(date "+%d/%m/%Y %T") INFO: Removing folders in Cloud Drive"
    rmdir $MERGERFSMOUNT >/dev/null
else
    echo "$(date "+%d/%m/%Y %T") WARN: Your Cloud Drive is not empty!"
fi
if [ -n "$(ls -A $RCLONEMOUNT)" ]; then
    echo "$(date "+%d/%m/%Y %T") INFO: Removing Rclone mount empty folder"
    rmdir $RCLONEMOUNT >/dev/null
else
    echo "$(date "+%d/%m/%Y %T") WARN: Rclone mount is not empty!"
fi
if [ -n "$(ls -A $RCLONEUPLOAD)" ]; then
    echo "$(date "+%d/%m/%Y %T") INFO: Removing Mergerfs local files folder"
else
    echo "$(date "+%d/%m/%Y %T") INFO: There are files pending upload"
fi

exit
