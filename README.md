
<center>
<h1 align="center">CloudStorage</h1>
<h4 align="center">Automate Uploads to Cloud Storage</h4>
<h5 align="Center">03/03/2020 - Script Version 0.05  ~ Installer Version 0.04
</center>

# Info
Automate uploading to your cloud storage. This uses "Mergerfs" for compatiability with Sonarr, Radarr, and streaming to Plex/Emby. Automate uploading from a local or remote machine running Ubuntu 18.04 or Debian 9/10.

# About
This guide will help you get started and is by no means the best way of doing things... this is what works for me. I created this repo for my own reference.

## Guides Included
- Installing Docker with Portainer frontend
- Setup Rclone and config
- Creating dockers using Portainer
- Using cron to schedule Rclone scripts

# Disclaimer

> I am not responsible for anything that could go wrong. I am not responsible for any data loss that could potentialy happen. You agree to use these scripts at your own risk.

# Installation
- We will be working from the main directory "/mnt"
- Script has only been tested on **Debian 9/10** and **Ubuntu 18.04**

:warning: Script is still experimental!

> Install/Update script
```
sudo apt update && sudo apt install curl -y && curl -s https://raw.githubusercontent.com/SenpaiBox/CloudStorage/master/install-scripts/install.sh | sudo bash
```

## Set Permissions

> The install script should set your permissions but if not you can run the following manually
```bash
$ sudo chmod -R +x /mnt && sudo chown -R $USER:$USER /mnt
```

## Change Fusermount Permission

> If the script fails to modify fuse.conf you can do this manually

> You must edit  /etc/fuse.conf to use option "allow_other" by uncommenting "user_allow_other"
```
$ sudo nano /etc/fuse.conf
```

# Configure Rclone

> Create your rclone.conf
```bash
$ rclone config
```
- I assume most use Google Drive so make sure you create your own client_id [INSTRUCTIONS HERE](https://rclone.org/drive/#making-your-own-client-id)
- Watch Spaceinvador One video for more help [WATCH HERE](https://youtu.be/-b9Ow2iX2DQ)

```bash
[googledrive]
type = drive
client_id = <CLIENTID>
client_secret = <CLIENTSECRET>
scope = drive
token = {"access_token":"**********"}
server_side_across_configs = true

[googledrive_encrypt]
type = crypt
remote = googledrive:encrypt
filename_encryption = standard
directory_name_encryption = true
password = <PASSWORD>
password2 = <PASSWORDSALT>
```
## Video Guide
View this step in a video example
- [How to Create An Rclone Remote](https://youtu.be/tVN3v8OHkeM)

# Rclone Scripts
### Do not run these scripts as sudo unless you are running everything as root or you will have permission problems
## Rclone Mount Script
### This script mounts your cloud storage to your local machine

> Make sure you edited **fuse.conf** first [CLICK HERE TO GO BACK](##Change-Fusermount-Permission)

> Configure the **rclone-mount** script. You only need to modify the "CONFIGURE" section

> Type "ID USER" replace USER with your own. This gives you UserID and GroupID

```bash
$ cd /mnt/user/cloudstorage/rclone    # Change to rclone scripts directory
$ nano rclone-mount.sh                # Edit the script
$ sh rclone-mount.sh                  # Run the script
```
```bash
# CONFIGURE
REMOTE="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
MEDIA="media" # Local share name NOTE: This is the directory you share to "Radarr,Sonarr,Plex,etc" EX: "/mnt/media"
USERID="1000" # Your user ID
GROUPID="1000" # Your group ID
```

## Rclone Unmount Script
### This script unmounts your cloud storage

> Configure the **rclone-unmount** script. You only need to modify the "CONFIGURE" section

```bash
$ cd /mnt/user/cloudstorage/rclone   # Change to rclone scripts directory
$ nano rclone-unmount.sh             # Edit the script
$ sh rclone-unmount.sh               # Run the script
```
```bash
# CONFIGURE
MEDIA="media" # Local share name NOTE: This is the directory you share to "Radarr,Sonarr,Plex,etc" EX: "/mnt/media"
```

## Rclone Upload Script
### This script uploads new files to your cloud storage

> Configure the **rclone-upload** script. You only need to modify the "CONFIGURE" section

```bash
$ cd /mnt/user/cloudstorage/rclone   # Change to rclone scripts directory
$ nano rclone-upload.sh              # Edit the script
$ sh rclone-upload.sh                # Run the script
```
```bash
# CONFIGURE
REMOTE="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
UPLOADREMOTE="googledrive_upload" # If you have a second remote created for uploads put it here. Otherwise use the same remote as REMOTE
MEDIA="media" # Local share name NOTE: The name you want to give your share mount
UPLOADLIMIT="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)

# SERVICE ACCOUNTS
# Drop your .json files in your "appdata/rclonedata/service_accounts"
# Name them "sa_account01.json" "sa_account02.json" etc.
USESERVICEACCOUNT="N" # Y/N. Choose whether to use Service Accounts NOTE: Bypass Google 750GB upload limit
SERVICEACCOUNTNUM="15" # Integer number of service accounts to use.

# DISCORD NOTIFICATIONS
DISCORD_WEBHOOK_URL="" # Enter your Discord Webhook URL for notifications. Otherwise leave empty to disable
DISCORD_ICON_OVERRIDE="https://raw.githubusercontent.com/rclone/rclone/master/graphics/logo/logo_symbol/logo_symbol_color_256px.png" # The poster user image
DISCORD_NAME_OVERRIDE="RCLONE" # The poster user name
```
## Testing
After you have configured each script run them manually to check if they are working.
The scripts are on PATH so you may run from any directory.
Make sure they are executable, if not look up how in the [Set Permissions](#setpermissions) section
```
$ rclone-mount
```

## Video Guide
View how to configure and run these scripts in a video example
- [Configure and run Rclone Scripts](https://youtu.be/BUUzEpF3XaM)

## Setup Cron Jobs

### Manual Entry
> Add each script to crontab: **rclone-mount, rclone-unmount, rclone-upload**

> Example: 0 */1 * * * /mnt/user/cloudstorage/rclone/rclone-mount.sh > /mnt/user/logs/rclone-mount.log 2>&1
```
$ crontab -e
```
### Using Provided Script

```
$ cd /mnt/cloudstorage/extras
$ sh add-to-cron.sh
```

- [Crontab Calculator](https://corntab.com/)

# Portainer

You can install and configure Dockers very easily using Portainer

Recommended Dockers from [Linuxserver](https://www.linuxserver.io/)
- Letsencrypt
- NZBget
- qBittorrent
- Sonarr
- Radarr

## Video Guides

- [How To Create a Docker in Portainer](https://youtu.be/0ibF-BZNsxQ)

## Changelog

### Rclone Scripts

- 3/03/2020 - v0.05 - Discord notifications and Service Accounts
- 2/29/2020 - v0.04 - Script Revision
- 2/18/2020 - v0.03 - Initial release

### Installer Script

- 3/05/20202 - v0.4 - Script factory resets and simple UI script
- 3/04/2020 - v0.3 - Script modifies fuse.conf
- 3/03/2020 - v0.2 - Added Watchtower
- 3/02/2020 - v0.1 - Combine all install scripts into one

## Acknowledgments

You can view the original Rclone scripts [BinsonBuzz/unraid_rclone_mount](https://github.com/BinsonBuzz/unraid_rclone_mount)

* BinsonBuzz for his super useful scripts :clap:
