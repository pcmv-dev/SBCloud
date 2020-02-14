#!/bin/bash

########################
#### Unmount Script ####
########################
####  Version 0.03  ####
########################
#######   VPS  #########
########################

#### Configuration ####
media="googlevps" # VPS share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # VPS share location

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

# Create location variables
appdata="/mnt/user/appdata/rclonedata/$media" # Rclone data folder location NOTE: Best not to touch this or map anything here
rcloneupload="$appdata/rclone_upload" # Staging folder of files to be uploaded
rclonemount="$appdata/rclone_mount" # Rclone mount folder
mergerfsmount="$mediaroot/$media" # Media share location

# Unmount Rclone
fusermount -u $rclonemount > /dev/null 2>&1
fusermount -u $mergerfsmount > /dev/null 2>&1

# Remove empty folders
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING UNMOUNT SCRIPT for \""${media}\"""
if [ "$(ls $appdata/)" != "" ]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Removing empty directories in \""$appdata\"""
    rmdir $rclonemount > /dev/null 2>&1 & rmdir $rcloneupload > /dev/null 2>&1
else
    echo "SUCCESS: $(date "+%m/%d/%Y %r") - No empty directories to remove"
fi

# Cleanup tracking files
if [ -f "$appdata/rclone_mount_running" ]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Rclone mount file detected, removing tracking file"
    rm $appdata/rclone_mount_running > /dev/null 2>&1
else
    echo "SUCCESS: $(date "+%m/%d/%Y %r") - Rclone mount exited properly"
fi
if [ -f "$apdata/rclone_upload_running" ]; then
    echo "INFO: $(date "+%m/%d/%Y %r") - Rclone upload file detected, removing tracking file"
    rm $appdata/rclone_upload_running > /dev/null 2>&1
else
    echo "SUCCESS: $(date "+%m/%d/%Y %r") - Rclone upload exited properly"
fi
exit
