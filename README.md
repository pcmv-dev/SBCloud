
<center>
<h1 align="center">vpscloudstorage</h1>
<h4 align="center">Rclone mount your GoogleDrive to upload from your VPS machine</h4>
<h5 align="Center">02/18/2020 - Version 0.03
</center>

# Info

Use these scripts to help you upload from your VPS. The idea is to setup Docker,Portainer, and NZBget/ruTorrent to download your media and then have Rclone upload it to your GoogleDrive to be able to watch from your Plex/Emby Server. Why might you want this? well check out the pros and cons below.


### Pros
- Fast Gigabit speeds (Depends on VPS Provider)
- Increased Bandwidth (Depends on VPS Provider)
- Save Bandwidth
- Build up your Media Library
- A seedbox

### Cons
- Extra cost, to pay for a VPS
- Working with a terminal
- Limited storage
- Low powered machine (Depends on VPS Provider)

# Setup
- Please read the Disclaimer at the bottom of the page. If you agree then you may proceed
- I have only tested scripts on **Debian 9/10** and **Ubuntu 18.04**

> Install git and curl
```
$ sudo apt update & sudo apt install git curl -y
```
> Download the scripts
```
$ sudo git clone https://github.com/SenpaiBox/vpscloudstorage.git /mnt/user/vpscloudstorage
```

> Make them executable
```
$ sudo chmod -R +x /mnt/user/vpscloudstorage
```
> Install Docker using the provided script or the given command
```
$ sudo curl -fsSL https://get.docker.com -o /mnt/user/vpscloudstorage/install-scripts/install-docker.sh 
$ sh /mnt/user/vpscloudstorage/install-scripts/install-docker.sh
```
> Run this to use Docker as non-root user NOTE: Change USER to your own
```
$ sudo usermod -aG docker USER
```
> You need to logout and log back in for your user to be added to Docker group
```
$ logout
$ docker ps <---After logging back in, no sudo required
```
> Change directory to 'vpscloudstorage/install-scripts' located in your user home folder
```
$ cd /mnt/user/vpscloudstorage/install-scripts
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
If you do not set this you will have problems with permissions
```
$ sudo nano /etc/fuse.conf
```
# Configure Rclone

> Take ownership of rclone.conf
```bash
$ sudo chown -R user:user $HOME/.config
```

> Create your rclone.conf
```bash
$ rclone config
```
- I assume most use Google Drive so make sure you create your own client_id [INSTRUCTIONS HERE](https://rclone.org/drive/#making-your-own-client-id)
- Watch Spaceinvador One video for more help [WATCH HERE](https://youtu.be/-b9Ow2iX2DQ)

```
[googledrive]
type = drive
client_id = **********
client_secret = **********
scope = drive
token = {"access_token":"**********"}
server_side_across_configs = true

[googledrive_encrypt]
type = crypt
remote = googledrive:encrypt
filename_encryption = standard
directory_name_encryption = true
password = **********
password2 = **********
```

## Rclone Mount Script
- **Make sure you run the commands as written!**
- **If you run the scripts as sudo you will have permission problems!**
> Make sure you edited **fuse.conf** first [CLICK HERE TO GO BACK](##Change-Fusermount-Permission)

> Configure the **vps-mount<i></i>.sh** script. You only need to modify the "CONFIGURE" section

```bash
$ cd /mnt/user/vpscloudstorage/rclone # Change to rclone scripts directory
$ nano vps-mount.sh                   # Edit the script
$ sh vps-mount.sh                     # Run the script
```
```bash
# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="vpsshare" # VPS share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # VPS share in your HOME directory
```

## Rclone Unmount Script

> Configure the **vps-unmount<i></i>.sh** script. You only need to modify the "CONFIGURE" section

```bash
$ cd /mnt/user/vpscloudstorage/rclone # Change to rclone scripts directory
$ nano vps-mount.sh                   # Edit the script
$ sh vps-unmount.sh                   # Run the script
```
```bash
# CONFIGURE
media="vpsshare" # VPS share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # VPS share in your HOME directory
```

## Rclone Upload Script

> Configure the **vps-upload<i></i>.sh** script. You only need to modify the "CONFIGURE" section

```bash
$ cd /mnt/user/vpscloudstorage/rclone # Change to rclone scripts directory
$ nano vps-mount.sh                   # Edit the script
$ sh vps-upload.sh                    # Run the script
```
```bash
# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="vpsshare" # VPS share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # VPS share in your HOME directory
uploadlimit="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)
```
## Testing
- After you have configured each script run them manually to check if they are working
- Make sure you are in the correct directory before you try to run the scripts
- Make sure they are executable. If not look up how in **Setup** section
```
$ sh vps-mount.sh
```
> Do one final permission sweep incase you missed a step
```bash
$ sudo chown -R user:user /mnt/user # Replace "user" with your own
$ sudo chmod -R +x /mnt/user
```

## Setup Cron Jobs

### Manual Entry
> Recommended to add your own cron entry per script: **vps-mount<i></i>.sh, vps-unmount<i></i>.sh, vps-upload<i></i>.sh**

> Example: 0 */1 * * * /mnt/user/vpscloudstorage/rclone/vps-mount.sh > /mnt/user/logs/vps-mount.log 2>&1
```
$ crontab -e
```
### Using Provided Script

:warning: Script is experimental!

> Configure **add-to-cron<i></i>.sh** script in "extras" folder. You only need to modify the "CONFIGURE" section

> Type "crontab -e" if you would like to change script schedule
```bash
$ cd /mnt/user/vpscloudstorage/extras # Change to extras scripts directory
$ nano add-to-cron.sh                 # Edit the script
$ sh add-to-cron.sh                   # Run the script
```
```bash
# CONFIGURE
media="googlevps" # VPS share name NOTE: The name you want to give your share mount
```
- [Crontab Calculator](https://corntab.com/)

# Portainer

You can install and configure Dockers very easily using Portainer. Now due to a VPS usually being an underpowred machine we should avoid overloading it. Depending on your VPS Provider your mileage may vary.

I recommend only installing **letsecrypt,nzbget,rutorrent,and portainer** then use scripts to organize and move your files.

> Create a "Network" so your containers can communicate with each other (needed for letsencrypt)

> Via terminal window or using Portainer (See Screenshot)
```
$ docker create network proxynet
```
> Networks > Add network
![Imgur](https://i.imgur.com/SXzepsf.png)

> Containers > "NZBGET" > Bottom of Page > Join Network
![Image](https://i.imgur.com/qKHpK7w.png)
> Add all containers to this network that you wish to reverse proxy


## Support

- Help is limited with these scripts as I do not have alot of freetime to give support
- Intended for personal testing

## Disclaimer

- I am not responsible for anything that could go wrong. I am not responsible for any data loss that could potentialy happen. You agree to use these scripts at your own risk.
