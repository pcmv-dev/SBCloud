
<center>
<h1 align="center">CloudStorage</h1>
<h4 align="center">Automate Uploads to Cloud Storage</h4>
<h5 align="Center">02/18/2020 - Version 0.03
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
- We will be working from the main directory "/mnt/user", you may change this if you prefer something else
- Scripts have only been tested on **Debian 9/10** and **Ubuntu 18.04**

> Install git and curl
```
$ sudo apt update & sudo apt install git curl -y
```
> Download the scripts
```
$ sudo git clone https://github.com/SenpaiBox/CloudStorage.git /mnt/user/cloudstorage
```

> Make them executable
```
$ sudo chmod -R +x /mnt/user/cloudstorage
```
> Install Docker using the provided script or the given command
```
$ sudo curl -fsSL https://get.docker.com -o /mnt/user/cloudstorage/install-scripts/install-docker.sh 
$ sh /mnt/user/cloudstorage/install-scripts/install-docker.sh
```
> Run this to use Docker as non-root user NOTE: Change USER to your own
```bash
$ sudo usermod -aG docker USER # Change USER to your own
```
> You need to logout and log back in for your user to be added to Docker group
```bash
$ docker ps # After logging back in, no sudo required
```
> Change directory to "cloudstorage/install-scripts" located in your user home folder
```
$ cd /mnt/user/cloudstorage/install-scripts
```
> Install Docker-Compose
```
$ sudo sh install-docker-compose.sh
```
> Install Portainer
```
$ sudo sh install-portainer.sh
```
> Install Mergerfs NOTE: for Debian 9/10 and Ubuntu 18.04 supported

Pick your OS > install-mergerfs-ubuntu<i></i>.sh | install-mergerfs-debian9<i></i>.sh | install-mergerfs-debian10<i></i>.sh

```
$ sudo sh install-mergerfs-ubuntu.sh
```
> Install Rclone
```
$ sudo sh install-rclone.sh
```
## Create Data Folder

>The next task is to create a directory where you want to store your media and appdata for **Rclone** and **Docker Containers**. The logs folder is optional, if you want to output your rclone scripts to a log.
```bash
$ sudo mkdir /mnt/user/appdata      # Root directory for Appdata
$ sudo mkdir /mnt/user/logs         # Root directory for Logs
$ sudo chown -R user:user /mnt/user # Change owner to current user
$ sudo chmod -R +x /mnt/user        # Change permissions to current user

```
> Change "user:user" with your username
## Change Fusermount Permission
> You must edit  /etc/fuse.conf to use option "allow_other" by uncommenting "user_allow_other"
If you do not set this, rclone-mount<i></i>.sh will throw an error.
```
$ sudo nano /etc/fuse.conf
```
## Video Guide
View all these steps in a video example
- [Install and Setup CloudStorage](https://youtu.be/XW_lkjJsB9I)
# Configure Rclone

> Create your rclone.conf
```bash
$ rclone config --config="/mnt/user/appdata/rclonedata/rclone.conf"
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
- [How to Create An Rclone Remote](https://youtu.be/XW_lkjJsB9I)

# Rclone Scripts
### Do not run these scripts as sudo unless you are running everything as root or you will have permission problems
## Rclone Mount Script
### This script mounts your cloud storage to your local machine

> Make sure you edited **fuse.conf** first [CLICK HERE TO GO BACK](##Change-Fusermount-Permission)

> Configure the **rclone-mount<i></i>.sh** script. You only need to modify the "CONFIGURE" section

```bash
$ cd /mnt/user/cloudstorage/rclone    # Change to rclone scripts directory
$ nano rclone-mount.sh                # Edit the script
$ sh rclone-mount.sh                  # Run the script
```
```bash
# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="media" # Local share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # Local share in your HOME directory
```

## Rclone Unmount Script
### This script unmounts your cloud storage

> Configure the **rclone-unmount<i></i>.sh** script. You only need to modify the "CONFIGURE" section

```bash
$ cd /mnt/user/cloudstorage/rclone   # Change to rclone scripts directory
$ nano rclone-unmount.sh               # Edit the script
$ sh rclone-unmount.sh               # Run the script
```
```bash
# CONFIGURE
media="media" # Local share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # Local share in your HOME directory
```

## Rclone Upload Script
### This script uploads new files to your cloud storage

> Configure the **rclone-upload<i></i>.sh** script. You only need to modify the "CONFIGURE" section

```bash
$ cd /mnt/user/cloudstorage/rclone   # Change to rclone scripts directory
$ nano rclone-upload.sh               # Edit the script
$ sh rclone-upload.sh                # Run the script
```
```bash
# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="media" # Local share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # Local share in your HOME directory
uploadlimit="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)
```
## Testing
After you have configured each script run them manually to check if they are working.
Make sure you are in the correct directory before you try to run the scripts.
Make sure they are executable, if not look up how in the [Installation](#installation) section
```
$ sh rclone-mount.sh
```
> Do one final permission sweep incase you missed a step
```bash
$ sudo chown -R user:user /mnt/user # Replace "user" with your own
$ sudo chmod -R +x /mnt/user
```
## Video Guide
View how to configure and run these scripts in a video example
- [Configure and run Rclone Scripts](https://youtu.be/8GlwCoV1SEc)

## Setup Cron Jobs

### Manual Entry
> Recommended to add your own cron entry per script: **rclone-mount<i></i>.sh, rclone-unmount<i></i>.sh, rclone-upload<i></i>.sh**

> Example: 0 */1 * * * /mnt/user/cloudstorage/rclone/rclone-mount.sh > /mnt/user/logs/rclone-mount.log 2>&1
```
$ crontab -e
```
### Using Provided Script

:warning: Script is experimental!

> Configure **add-to-cron<i></i>.sh** script in "extras" folder. You only need to modify the "CONFIGURE" section

> Type "crontab -e" if you would like to change script schedule

> If you would like to reset your cron tasks type "crontab -r"
```bash
$ cd /mnt/user/cloudstorage/extras  # Change to extras scripts directory
$ nano add-to-cron.sh               # Edit the script
$ sh add-to-cron.sh                 # Run the script
```
```bash
# CONFIGURE
media="cloudstorage" # Local share name NOTE: The name you want to give your share mount
```
- [Crontab Calculator](https://corntab.com/)
## Video Guide
View how to setup scripts in a cron schedule
- [Setup Rclone Scripts in Cron](https://youtu.be/osfKtjjHrfs)

# Portainer

You can install and configure Dockers very easily using Portainer

Recommended Dockers from [Linuxserver](https://www.linuxserver.io/)
- Letsencrypt
- NZBget
- ruTorrent
- Sonarr
- Radarr

## Video Guides

- [How To Create a Docker in Portainer](https://youtu.be/0ibF-BZNsxQ)
