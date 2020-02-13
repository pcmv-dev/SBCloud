#!/bin/bash

########################
#### Unmount Script ####
########################
####  Version 1.01  ####
########################
#######   VPS  #########
########################

#### Configuration ####
vault="googlevps" # VPS share name NOTE: The name you want to give your remote mount
share="/mnt/user/$vault" # VPS share location 
data="/mnt/user/appdata/rclonedata/$vault" # Rclone data folder location NOTE: Best not to touch this or map anything here

# Remove empty folders
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING UNMOUNT SCRIPT for \""${vault}\"""
if [[ "$(ls $data/)" != "" ]]; then
echo "INFO: $(date "+%m/%d/%Y %r") - Removing empty directories in \""$data\"""
rmdir $data/rclone_mount & rmdir $data/rclone_upload & rmdir $data/mergerfs
else
echo "SUCCESS: $(date "+%m/%d/%Y %r") - No empty directories to remove"
fi

# Cleanup tracking files
if [[ -f "$data/rclone_mount_running" ]]; then
echo "INFO: $(date "+%m/%d/%Y %r") - Rclone mount file detected, removing tracking file"
find $data -name mount_running -delete
else
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Rclone mount exited properly"
fi
if [[ -f "$data/rclone_upload_running" ]]; then
echo "INFO: $(date "+%m/%d/%Y %r") - Rclone upload file detected, removing tracking file"
find $data -name upload_running -delete
else
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Rclone upload exited properly"
fi
exit
