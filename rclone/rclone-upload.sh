#!/bin/bash

#######################
#### Upload Script ####
#######################
####  Version 0.05  ###
#######################

# CONFIGURE
REMOTE="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
UPLOADREMOTE="googledrive_upload" # If you have a second remote created for uploads put it here. Otherwise use the same remote as REMOTE
MEDIA="media" # Local share name NOTE: The name you want to give your share mount
MEDIAROOT="/mnt" # Local share directory
UPLOADLIMIT="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)

# SERVICE ACCOUNTS
USESERVICEACCOUNT="N" # Y/N. Choose whether to use Service Accounts NOTE: Bypass Google 750GB upload limit
SERVICEACCOUNTNUM="15" # Integer number of service accounts to use.

# DISCORD NOTIFICATIONS
DISCORD_WEBHOOK_URL="" # Enter your Discord Webhook URL for notifications. Otherwise leave empty to disable
DISCORD_ICON_OVERRIDE="https://raw.githubusercontent.com/rclone/rclone/master/graphics/logo/logo_symbol/logo_symbol_color_256px.png"
DISCORD_NAME_OVERRIDE="RCLONE"

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################
# Create location variables
APPDATA="/mnt/appdata/rclonedata/$MEDIA" # Rclone data folder location
RCLONEUPLOAD="$APPDATA/rclone_upload" # Staging folder of files to be uploaded NOTE: Local files
RCLONEMOUNT="$APPDATA/rclone_mount" # Rclone mount folder NOTE: Do not drop files here, it is unreliable
MERGERFSMOUNT="$MEDIAROOT/$MEDIA" # Local share location NOTE: This is where your files go
RCLONECONF="$APPDATA/rclone.conf" # Rclone config file location
LOCKFILE="$APPDATA/upload.lock" # Rclone upload lock file
SERVICEACCOUNTDIR="$APPDATA/service_accounts" # Path to your Service Account's .json files
SERVICEACCOUNTFILE="sa_account" # Service Account file name without "00.json"
LOGFILE="/mnt/logs/rclone-upload.log" # Log file for upload

# Check if script is already running
echo " ==== STARTING UPLOAD SCRIPT ===="
if [ -f "$LOCKFILE" ]; then
    echo "$(date "+%d.%m.%Y %T") WARN: Upload already in progress! Script will exit..."
    exit
else
    touch $LOCKFILE
fi

# Check if Rclone/Mergerfs mount created
if [ -n "$(ls -A $MERGERFSMOUNT)" ]; then
    echo "$(date "+%d.%m.%Y %T") ERROR: Check Failed! Rclone is not mounted, please check your configuration"
    rm $APPDATA/upload_running
    exit
else
    echo "$(date "+%d.%m.%Y %T") SUCCESS: Check Passed! Your Cloud Drive is mounted, proceeding with upload"
fi

# Rotating serviceaccount.json file if using Service Accounts
if [ $USESERVICEACCOUNT == 'Y' ]; then
    cd $APPDATA
    COUNTERNUM=$(find -name 'counter*' | cut -c 11,12)
    CONTERCHECK="1"
    if [ "$COUNTERNUM" -ge "$CONTERCHECK" ];then
        echo "$(date "+%d.%m.%Y %T") INFO: Counter file found for ${UPLOADREMOTE}."
    else
        echo "$(date "+%d.%m.%Y %T") INFO: No counter file found for ${UPLOADREMOTE}. Creating counter_1."
        touch $APPDATA/counter_1
        COUNTERNUM="1"
    fi
    SERVICEACCOUNT="--drive-service-account-file=$SERVICEACCOUNTDIR/$SERVICEACCOUNTFILE$COUNTERNUM.json"
    echo "$(date "+%d.%m.%Y %T") INFO: Adjusted Service Account file for upload remote ${UPLOADREMOTE} to ${SERVICEACCOUNTFILE}${COUNTERNUM}.json based on counter ${COUNTERNUM}."
else
    echo "$(date "+%d.%m.%Y %T") INFO: Uploading using upload remote ${UPLOADREMOTE}"
    SERVICEACCOUNT=""
fi

# Rclone upload flags
echo "==== RCLONE DEBUG ===="
rclone_move() {
    rclone_command=$(
    rclone move $RCLONEUPLOAD/ $UPLOADREMOTE: $SERVICEACCOUNT -vP \
    --config=$RCLONECONF \
    --user-agent=$UPLOADREMOTE \
    --log-file=$LOGFILE \
    --stats=9999m \
    --log-level INFO \
    --buffer-size 64M \
    --drive-chunk-size 128M \
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
    echo "$rclone_command"
}
echo "======================"
rclone_move

if [ "$DISCORD_WEBHOOK_URL" != "" ]; then
    
    rclone_sani_command="$(echo $rclone_command | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')" # Remove all escape sequences
    
    # Notifications assume following rclone ouput:
    # Transferred: 0 / 0 Bytes, -, 0 Bytes/s, ETA - Errors: 0 Checks: 0 / 0, - Transferred: 0 / 0, - Elapsed time: 0.0s
    
    transferred_amount=${rclone_sani_command#*Transferred: }
    transferred_amount=${transferred_amount%% /*}
    
    send_notification() {
        output_transferred_main=${rclone_sani_command#*Transferred: }
        output_transferred_main=${output_transferred_main% Errors*}
        output_errors=${rclone_sani_command#*Errors: }
        output_errors=${output_errors% Checks*}
        output_checks=${rclone_sani_command#*Checks: }
        output_checks=${output_checks% Transferred*}
        output_transferred=${rclone_sani_command##*Transferred: }
        output_transferred=${output_transferred% Elapsed*}
        output_elapsed=${rclone_sani_command##*Elapsed time: }
        
        notification_data='{
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
                            "value": "'"$output_transferred_main"'"
                        },
                        {
                            "name": "Errors",
                            "value": "'"$output_errors"'"
                        },
                        {
                            "name": "Checks",
                            "value": "'"$output_checks"'"
                        },
                        {
                            "name": "Transferred",
                            "value": "'"$output_transferred"'"
                        },
                        {
                            "name": "Elapsed time",
                            "value": "'"$output_elapsed"'"
                        }
                    ],
                    "thumbnail": {
                        "url": null
                    }
                }
            ]
        }'
        
        curl -H "Content-Type: application/json" -d "$notification_data" $DISCORD_WEBHOOK_URL
    }
    
    if [ "$transferred_amount" != "0" ]; then
        send_notification
    fi
    
fi

# Update Service Account counter
if [  $USESERVICEACCOUNT == 'Y' ]; then
    if [ "$COUNTERNUM" == "$SERVICEACCOUNTNUM" ];then
        rm $APPDATA/counter_*
        touch $APPDATA/counter_1
        echo "$(date "+%d.%m.%Y %T") INFO: Final counter used - resetting loop and created counter_1."
    else
        rm $APPDATA/counter_*
        COUNTERNUM=$((COUNTERNUM+1))
        touch $APPDATA/counter_$COUNTERNUM
        echo "$(date "+%d.%m.%Y %T") INFO: Created counter_${COUNTERNUM} for next upload run."
    fi
else
    echo "$(date "+%d.%m.%Y %T") INFO: Not utilising service accounts."
fi

# Remove tracking files
rm -f $LOCKFILE
echo "$(date "+%d.%m.%Y %T") SUCCESS: Upload Complete"
exit
