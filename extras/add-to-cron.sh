#!/bin/bash
# This will add rclone scripts to crontab
# To view your cronjobs type in terminal "crontab -l"
# If you need to edit the schedule type in terminal "crontab -e"
# To delete all cron tasks type in terminal "crontab -r"
# Logs are located in "/mnt/logs"

tee <<-EOF

Rclone Cronjob Tasks

[1] Add Rclone scripts to crontab
[2] Remove all cronjobs in crontab

[E] Exit

EOF

if [ `whoami` = root ]; then
    echo "Do not run as sudo/root! Will now exit..."
    exit
fi
APPDATA="/mnt/cloudstorage/rclone" # Location of your Rclone scripts
read -p 'Type a Number | Press [ENTER]: ' typed </dev/tty
if [ "$typed" == "1" ]; then
    (crontab -l 2>/dev/null; echo "") | crontab -
    (crontab -l 2>/dev/null; echo "# Rclone scripts") | crontab -
    (crontab -l 2>/dev/null; echo "@hourly $APPDATA/rclone-mount > /mnt/logs/rclone-mount.log 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "*/15 * * * * $APPDATA/rclone-upload > /mnt/logs/rclone-upload.log 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "@reboot $APPDATA/rclone-unmount > /mnt/logs/rclone-unmount.log 2>&1") | crontab -
    echo
    crontab -l
    /etc/init.d/cron reload
    elif [ "$typed" == "2" ]; then
    crontab -r -i
    elif [ "$typed" == "E" ] || [ "$typed" == "e" ]; then
    exit
fi
exit