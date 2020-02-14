#!/bin/bash

#######################
#### Upload Script ####
#######################
####  Version 0.03  ###
#######################
#######   VPS  ########
#######################

# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="googlevps" # VPS share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # VPS share location
uploadlimit="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

# Create location variables
appdata="/mnt/user/appdata/rclonedata/$media" # Rclone data folder location NOTE: Best not to touch this or map anything here
rcloneupload="$appdata/rclone_upload" # Staging folder of files to be uploaded
rclonemount="$appdata/rclone_mount" # Rclone mount folder
mergerfsmount="$mediaroot/$media" # Media share location

# Check if script is already running
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING UPLOAD SCRIPT for \""${media}\"""
if [[ -f "$appdata/rclone_upload_running" ]]; then
echo "WARN: $(date "+%m/%d/%Y %r") - Upload already in progress!"
exit
else
touch $data/rclone_upload_running
fi

# Check if rclone mount created
if [[ -f "$rclonemount/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${media}\"" is mounted, proceeding with upload"
else
echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! \""${media}\"" is not mounted, please check your configuration"
rm $appdata/rclone_upload_running
exit
fi

# Rclone upload flags
echo "==== RCLONE DEBUG ===="
rclone move $rcloneupload/ $remote: \
--user-agent="$remote" \
--log-level INFO \
--buffer-size 32M \
--drive-chunk-size 16M \
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
rm $appdata/rclone_upload_running
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Upload Complete"
exit
