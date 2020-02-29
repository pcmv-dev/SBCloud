#!/bin/bash
# This will add rclone scripts to crontab
# You can only run this script once
# To view your cronjobs type in terminal "crontab -l"
# If you need to edit the schedule type in terminal "crontab -e"
# To delete all cron tasks type in terminal "crontab -r"
# Logs are located in "/mnt/user/logs"

# CONFIGURE
media="media" # rclone share name NOTE: The name you want to give your share mount

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

appdata="/mnt/user/appdata/rclonedata/$media"
mkdir -p $appdata
if [ -f "$appdata/cron_job_added" ]; then
    echo "Cronjob already added..."
    echo "Edit with \""crontab -e\"" or reset with \""crontab -r\"""
    exit
else
    echo "Added rclone scripts to crontab"
    touch $appdata/cron_job_added
    (crontab -l 2>/dev/null; echo "# Rclone scripts for \""${media}\""") | crontab -
    (crontab -l 2>/dev/null; echo "@hourly /mnt/user/cloudstorage/rclone/rclone-mount.sh > /mnt/user/logs/rclone-mount.log 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "*/15 * * * * /mnt/user/cloudstorage/rclone/rclone-upload.sh > /mnt/user/logs/rclone-upload.log 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "@reboot /mnt/user/cloudstorage/rclone/rclone-unmount.sh > /mnt/user/logs/rclone-unmount.log 2>&1") | crontab -
    /etc/init.d/cron reload
fi
exit