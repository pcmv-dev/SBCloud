#!/bin/bash

#######################
#### Upload Script ####
#######################
####  Version 0.06  ###
#######################

# CONFIGURE
REMOTE="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
UPLOADREMOTE="googledrive_upload" # If you have a second remote created for uploads put it here. Otherwise use the same remote as REMOTE
MEDIA="media" # Local share name NOTE: The name you want to give your share mount
UPLOADLIMIT="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)

# SERVICE ACCOUNTS
# Drop your .json files in your "appdata/rclonedata/service_accounts"
# Name them "sa_account1.json" "sa_account2.json" etc.
USESERVICEACCOUNT="N" # Y/N. Choose whether to use Service Accounts NOTE: Bypass Google 750GB upload limit
SERVICEACCOUNTNUM="15" # Integer number of service accounts to use.

# DISCORD NOTIFICATIONS
DISCORD_WEBHOOK_URL="" # Enter your Discord Webhook URL for notifications. Otherwise leave empty to disable
DISCORD_ICON_OVERRIDE="https://raw.githubusercontent.com/rclone/rclone/master/graphics/logo/logo_symbol/logo_symbol_color_256px.png" # The bot user image
DISCORD_NAME_OVERRIDE="RCLONE" # The bot user name

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

# Make sure we are not running as root
if [[ `whoami` == root ]]; then
    echo "Do not run as sudo/root!"
    exit
fi

# Advanced Settings, Edit only if you know what you are doing
MEDIAROOT="/mnt" # Your root directory. The directory where you want everything saved to EX: "/mnt/media" "/mnt/appdata"
APPDATA="$MEDIAROOT/rclonedata" # Rclone data folder location
RCLONEUPLOAD="$APPDATA/rclone_upload" # Staging folder of files to be uploaded NOTE: Local files
RCLONEMOUNT="$APPDATA/rclone_mount" # Rclone mount folder NOTE: Do not drop files here, it is unreliable
MERGERFSMOUNT="$MEDIAROOT/$MEDIA" # Local share location NOTE: This is where your files go
RCLONECONF="$HOME/.config/rclone/rclone.conf" # Rclone config file location
LOCKFILE="$APPDATA/upload.lock" # Rclone upload lock file
SERVICEACCOUNTDIR="$MEDIAROOT/appdata/rclonedata/service_accounts" # Path to your Service Account's .json files
SERVICEACCOUNTFILE="sa_account" # Service Account file name without "00.json"
LOGFILE="$MEDIAROOT/logs/$REMOTE/rclone-upload.log" # Log file for upload

# Check if script is already running
echo " ==== STARTING UPLOAD SCRIPT ===="
if [[ -f "$LOCKFILE" ]]; then
    echo "$(date "+%d/%m/%Y %T") WARN: Upload already in progress! Script will exit..."
    exit
else
    touch $LOCKFILE
fi

# Check if Rclone/Mergerfs mount created
if [[ -n "$(ls -A $MERGERFSMOUNT 2>/dev/null)" ]]; then
    echo "$(date "+%d/%m/%Y %T") SUCCESS: Check Passed! Your Cloud Drive is mounted, proceeding with upload"
    rm -f $LOGFILE 2>/dev/null
else
    echo "$(date "+%d/%m/%Y %T") ERROR: Check Failed! Your Cloud Drive is not mounted, please check your configuration"
    rm -f $LOCKFILE
    exit
fi

# Rotating serviceaccount.json file if using Service Accounts
if [[ $USESERVICEACCOUNT == 'Y' ]]; then
    cd $APPDATA
    COUNTERNUM=$(find -name 'counter*' | cut -c 11,12)
    CONTERCHECK="1"
    if [[ "$COUNTERNUM" -ge "$CONTERCHECK" ]];then
        echo "$(date "+%d/%m/%Y %T") INFO: Counter file found for ${UPLOADREMOTE}"
    else
        echo "$(date "+%d/%m/%Y %T") INFO: No counter file found for ${UPLOADREMOTE}. Creating counter_1"
        touch $APPDATA/counter_1
        COUNTERNUM="1"
    fi
    SERVICEACCOUNT="--drive-service-account-file=$SERVICEACCOUNTDIR/$SERVICEACCOUNTFILE$COUNTERNUM.json"
    echo "$(date "+%d/%m/%Y %T") INFO: Adjusted Service Account file for upload remote ${UPLOADREMOTE} to ${SERVICEACCOUNTFILE}${COUNTERNUM}.json based on counter ${COUNTERNUM}"
else
    echo "$(date "+%d/%m/%Y %T") INFO: Uploading using ${UPLOADREMOTE} remote"
    SERVICEACCOUNT=""
fi

# Rclone upload flags
mkdir -p $MEDIAROOT/logs/$REMOTE 2>/dev/null
RCLONE_MOVE() {
    RCLONE_COMMAND=$(
    rclone move $RCLONEUPLOAD/ $UPLOADREMOTE: $SERVICEACCOUNT -vP \
    --config=$RCLONECONF \
    --user-agent=$UPLOADREMOTE \
    --log-file=$LOGFILE \
    --stats=9999m \
    --buffer-size 512M \
    --drive-chunk-size 512M \
    --use-mmap \
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
    --bwlimit $UPLOADLIMIT \
    --drive-stop-on-upload-limit \
    --min-age 10m
    )
    echo "==== RCLONE DEBUG ===="
    echo "$RCLONE_COMMAND"
    echo "======================"
}
RCLONE_MOVE

if [[ "$DISCORD_WEBHOOK_URL" != "" ]]; then
    
    RCLONE_SANI_COMMAND="$(echo $RCLONE_COMMAND | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')" # Remove all escape sequences
    
    # Notifications assume following rclone ouput:
    # Transferred: 0 / 0 Bytes, -, 0 Bytes/s, ETA
    # Checks: 0 / 0
    # Deleted: 0
    # Transferred: 0 / 0,
    # Elapsed time: 0.0s
    
    TRANSFERRED_AMOUNT=${RCLONE_SANI_COMMAND#*Transferred: }
    TRANSFERRED_AMOUNT=${TRANSFERRED_AMOUNT%% /*}
    
    SEND_NOTIFICATION() {
        OUTPUT_TRANSFERRED_MAIN=${RCLONE_SANI_COMMAND#*Transferred: }
        OUTPUT_TRANSFERRED_MAIN=${OUTPUT_TRANSFERRED_MAIN% Checks*}
        OUTPUT_CHECKS=${RCLONE_SANI_COMMAND#*Checks: }
        OUTPUT_CHECKS=${OUTPUT_CHECKS% Deleted*}
        OUTPUT_DELETED=${RCLONE_SANI_COMMAND#*Deleted: }
        OUTPUT_DELETED=${OUTPUT_DELETED% Transferred*}
        OUTPUT_TRANSFERRED=${RCLONE_SANI_COMMAND##*Transferred: }
        OUTPUT_TRANSFERRED=${OUTPUT_TRANSFERRED% Elapsed*}
        OUTPUT_ELAPSED=${RCLONE_SANI_COMMAND##*Elapsed time: }
        
        NOTIFICATION_DATA='{
            "username": "'"$DISCORD_NAME_OVERRIDE"'",
            "avatar_url": "'"$DISCORD_ICON_OVERRIDE"'",
            "content": null,
            "embeds": [
                {
                    "title": "Rclone Upload Task: Success!",
                    "color": 4094126,
                    "fields": [
                        {
                            "name": "Transferred",
                            "value": "'"$OUTPUT_TRANSFERRED_MAIN"'"
                        },
                        {
                            "name": "Checks",
                            "value": "'"$OUTPUT_CHECKS"'"
                        },
                        {
                            "name": "Deleted",
                            "value": "'"$OUTPUT_DELETED"'"
                        },
                        {
                            "name": "Transferred",
                            "value": "'"$OUTPUT_TRANSFERRED"'"
                        },
                        {
                            "name": "Elapsed time",
                            "value": "'"$OUTPUT_ELAPSED"'"
                        }
                    ],
                    "thumbnail": {
                        "url": null
                    }
                }
            ]
        }'
        
        curl -H "Content-Type: application/json" -d "$NOTIFICATION_DATA" $DISCORD_WEBHOOK_URL
    }
    
    if [[ "$TRANSFERRED_AMOUNT" != "0" ]]; then
        SEND_NOTIFICATION
    fi
    
fi

# Update Service Account counter
if [[  $USESERVICEACCOUNT == 'Y' ]]; then
    if [ "$COUNTERNUM" == "$SERVICEACCOUNTNUM" ];then
        rm $APPDATA/counter_*
        touch $APPDATA/counter_1
        echo "$(date "+%d/%m/%Y %T") INFO: Final counter used - resetting loop and created counter_1"
    else
        rm $APPDATA/counter_*
        COUNTERNUM=$((COUNTERNUM+1))
        touch $APPDATA/counter_$COUNTERNUM
        echo "$(date "+%d/%m/%Y %T") INFO: Created counter_${COUNTERNUM} for next upload run"
    fi
else
    echo "$(date "+%d/%m/%Y %T") INFO: Not utilising service accounts"
fi

# Remove lock file and exit
rm -f $LOCKFILE
echo "$(date "+%d/%m/%Y %T") SUCCESS: Upload Complete"
exit