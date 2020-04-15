#!/bin/bash
# This will add rclone scripts to crontab
# To view your cronjobs type in terminal "crontab -l"
# If you need to edit the schedule type in terminal "crontab -e"
# To delete all cron tasks type in terminal "crontab -r"

if [ `whoami` == root ]; then
    echo "Do not run as sudo/root!"
    exit
fi
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RCLONE CRONTAB
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 This will add "rclone-upload" to crontab
 To view your cronjobs type in terminal "crontab -l"
 If you need to edit the schedule type in terminal "crontab -e"
 Logs are located in "/mnt/logs"

[1] Add Rclone upload schedule
[2] Reset crontab

[3] Cancel/Exit

EOF
read -p "Type a Number | Press [ENTER]: " typed </dev/tty
if [[ "$typed" == "1" ]]; then
    read -p "Enter how long to wait between uploads (In minutes) [1-59]: " minute </dev/tty
    (crontab -l 2>/dev/null; echo "") | crontab -
    (crontab -l 2>/dev/null; echo "# Rclone upload script") | crontab -
    (crontab -l 2>/dev/null; echo "*/${minute} * * * * /mnt/sbcloud/rclone/rclone-upload 2>&1") | crontab -
    echo
    crontab -l
    /etc/init.d/cron reload
    elif [[ "$typed" == "2" ]]; then
    crontab -r -i
    elif [[ "$typed" == "3" ]]; then
    exit
fi
exit