#!/bin/bash
# This will add rclone scripts to crontab
# To view your cronjobs type in terminal "crontab -l"
# If you need to edit the schedule type in terminal "crontab -e"
# To delete all cron tasks type in terminal "crontab -r"
# Logs are located in "/mnt/logs"

if [ `whoami` = root ]; then
    echo "Do not run as sudo/root!"
    exit
fi
tee <<-EOF

Add Rclone scripts to crontab

[1] Add Rclone scripts to crontab
[2] Reset crontab

[3] Exit

EOF

read -p 'Type a Number | Press [ENTER]: ' typed </dev/tty
if [ "$typed" -eq "1" ]; then
    (crontab -l 2>/dev/null; echo "") | crontab -
    (crontab -l 2>/dev/null; echo "# Rclone scripts") | crontab -
    (crontab -l 2>/dev/null; echo "@hourly /mnt/cloudstorage/rclone/rclone-mount > /mnt/logs/rclone-mount.log 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "*/15 * * * * /mnt/cloudstorage/rclone/rclone-upload 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "@reboot /mnt/cloudstorage/rclone/rclone-unmount > /mnt/logs/rclone-unmount.log 2>&1") | crontab -
    echo
    crontab -l
    /etc/init.d/cron reload
    elif [ "$typed" -eq "2" ]; then
    crontab -r -i
    elif [ "$typed" = "3" ]; then
    exit
fi
exit