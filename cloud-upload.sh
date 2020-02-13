#!/bin/bash

#######################
#### Upload Script ####
#######################
####  Version 1.01  ###
#######################
#######   VPS  ########
#######################

#### Configuration ####
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
vault="googlevps" # VPS share name NOTE: The name you want to give your remote mount
uploadlimit="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)
share="/mnt/user/$vault" # VPS share location 
data="/mnt/user/appdata/rclonedata/$vault" # Rclone data folder location NOTE: Best not to touch this or map anything here

# Check if script is already running
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING UPLOAD SCRIPT for \""${vault}\"""
if [[ -f "$data/rclone_upload_running" ]]; then
echo "WARN: $(date "+%m/%d/%Y %r") - Upload already in progress!"
exit
else
touch $data/rclone_upload_running
fi

# Check if rclone mount created
if [[ -f "$data/rclone_mount/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault}\"" is mounted, proceeding with upload"
else
echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! \""${vault}\"" is not mounted, please check your configuration"
rm $data/rclone_upload_running
exit
fi

# Rclone upload flags
echo "==== RCLONE DEBUG ===="
rclone move $data/rclone_upload/ $remote: \
--user-agent="$remote" \
--log-level INFO \
--buffer-size 64M \
--drive-chunk-size 64M \
--tpslimit 4 \
--checkers 4 \
--transfers 4 \
--order-by modtime,ascending \
--exclude downloads/** \
--exclude .Recycle.Bin/** \
--exclude *fuse_hidden* \
--exclude *_HIDDEN \
--exclude .recycle** \
--exclude *.backup~* \
--exclude *.partial~*  \
--delete-empty-src-dirs \
--bwlimit $uploadlimit \
--drive-stop-on-upload-limit \
--min-age 10m
echo "======================"

# Remove tracking files
rm $data/rclone_upload_running
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Upload Complete"
exit
