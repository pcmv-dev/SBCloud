#!/bin/bash
# This will add rclone scripts to crontab
# To view your cronjobs type in terminal "crontab -l"
# If you need to edit the schedule type in terminal "crontab -e"
# To delete all cron tasks type in terminal "crontab -r"
# Logs are located in "/mnt/logs"

if [ `whoami` == root ]; then
    echo "Do not run as sudo/root!"
    exit
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RCLONE CRONTAB
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 This will add rclone scripts to crontab
 To view your cronjobs type in terminal "crontab -l"
 If you need to edit the schedule type in terminal "crontab -e"
 Logs are located in "/mnt/logs"

[1] Add Rclone scripts to crontab
[2] Reset crontab

[3] Cancel/Exit

EOF
read -p "Type a Number | Press [ENTER]: " typed </dev/tty
if [ "$typed" == "1" ]; then
    read -p "Enter your Rclone Remote name: " remote </dev/tty
    read -p "Enter how long to wait between uploads [1-59]: " minute </dev/tty
    (crontab -l 2>/dev/null; echo "") | crontab -
    (crontab -l 2>/dev/null; echo "# Rclone scripts") | crontab -
    (crontab -l 2>/dev/null; echo "*/${minute} * * * * /mnt/cloudstorage/rclone/rclone-upload 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "@hourly /mnt/cloudstorage/rclone/rclone-mount > /mnt/logs/${remote}/rclone-mount.log 2>&1") | crontab -
    (crontab -l 2>/dev/null; echo "@reboot /mnt/cloudstorage/rclone/rclone-unmount > /mnt/logs/${remote}/rclone-unmount.log 2>&1") | crontab -
    echo
    crontab -l
    /etc/init.d/cron reload
    elif [ "$typed" == "2" ]; then
    crontab -r -i
    elif [ "$typed" == "3" ]; then
    exit
fi
exit