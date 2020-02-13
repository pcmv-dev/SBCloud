#!/bin/bash

######################
#### Mount Script ####
######################
#### Version 0.01 ####
######################
#######   VPS  #######
######################

#### Configuration ####
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
vault="googlevps" # VPS share name NOTE: The name you want to give your remote mount
share="/mnt/user/$vault" # VPS share location 
data="/mnt/user/appdata/rclonedata/$vault" # Rclone data folder location NOTE: Best not to touch this or map anything here

# Check if script is already running
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING MOUNT SCRIPT for \""${vault}\"""
echo "INFO: $(date "+%m/%d/%Y %r") - Checking if script is already running"
if [[ -f "$data/rclone_mount_running" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault}\"" is already mounted"
exit
else
touch $data/rclone_mount_running
fi

# Create directories
mkdir -p $data # Rclone data folder
mkdir -p $data/rclone_mount # Rclone mount folder
mkdir -p $data/rclone_upload # Staging folder of files to be uploaded
mkdir -p $share # VPS share

# Check if rclone mount already created
if [[ -f "$data/rclone_mount/mountcheck" ]]; then
echo "WARN: $(date "+%m/%d/%Y %r") - Remote already mounted to rclone mount"
else
echo "INFO: $(date "+%m/%d/%Y %r") - Mounting remote to \""$data/rclone_mount\"""

# Creating mountcheck file in case it doesn't already exist
echo "INFO: $(date "+%m/%d/%Y %r") - Recreating mountcheck file for \""${remote}\"" remote"
echo "#### RCLONE DEBUG ####"
echo
touch /tmp/mountcheck
rclone copy /tmp/mountcheck $remote: --no-traverse --log-level INFO
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Created mountcheck file for \""${remote}\"" remote"

# Rclone mount command and flags
rclone mount \
--log-level ERROR \
--allow-other \
--dir-cache-time 720h \
--vfs-read-chunk-size 128M \
--vfs-read-chunk-size-limit off \
--vfs-cache-mode writes \
$remote: $data/rclone_mount &

# Check if mount successful
echo "INFO: $(date "+%m/%d/%Y %r") - Mount in progress please wait..."
sleep 5
echo "INFO: $(date "+%m/%d/%Y %r") - Proceeding..."
if [[ -f "$data/rclone_mount/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! remote mounted to rclone mount"
else
echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! please check your configuration"
rm $data/rclone_mount_running
exit
fi
fi
# Check share mount
if [[ -f "$share/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault}\"" is mounted"
else

# Check if mergerfs already installed
if [[ -f "/usr/bin/mergerfs" ]]; then
echo "INFO: $(date "+%m/%d/%Y %r") - Mergerfs is installed"
else
echo "ERROR: $(date "+%m/%d/%Y %r") - Please install Mergerfs first"
exit
fi

# Create mergerfs mount
mergerfs $data/rclone_upload:$data/rclone_mount $share -o rw,async_read=false,use_ino,allow_other,func.getattr=newest,category.action=all,category.create=ff,cache.files=partial,dropcacheonclose=true
if [[ -f "$share/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault}\"" is mounted"
echo "#### REMOTE DIRECTORIES ####"
rclone lsd $remote:
else
echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! \""${vault}\"" failed to mount, please check your configuration"
rm $data/rclone_mount_running
echo
exit
fi
fi
exit
