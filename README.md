
<center>
<h1 align="center">VPSCloudStorage</h1>
<h4 align="center">Rclone mount your GoogleDrive to upload from your VPS machine</h4>
<h5 align="Center"><strong>02/18/2020 - Version 0.03</strong>
</center>

# Info

Use these scripts to help you upload from your VPS. The idea is to setup Docker,Portainer, and NZBget/ruTorrent to download your media and then have Rclone upload it to your GoogleDrive to be able to watch from your Plex/Emby Server. Why might you want this? well check out the pros and cons below.

### Pros
- You have slow download/upload, so you use your VPS that has fast Gigabit speeds
- Bandwidth is freed up on your end
- You can upload media, quicker

### Cons
- Extra cost, to pay for a VPS
- Working with a terminal
- You can only download files that are smaller than your VPS storage

# Setup
- I have only tested scripts on <strong>Debian 9/10</strong> and <strong>Ubuntu 18.04<strong>

> Install git and curl
```
$ sudo apt update & sudo apt install git curl -y
```
> Download the scripts
```
$ git clone https://github.com/SenpaiBox/VPSCloudStorage.git ~/VPSCloudStorage
```

> Make them executable
```
$ sudo chmod -R +x ~/VPSCloudStorage
```
> Install Docker using the provided script or the given command
```
$ curl -fsSL https://get.docker.com -o install-docker.sh 
$ sh install-docker.sh
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
> Change directory to 'VPSCloudStorage/install-scripts' located in your user home folder
```
$ cd ~/VPSCloudStorage/install-scripts
```
> Install Docker-Compose
```
$ sudo sh install-docker-compose.sh
```
> Install Portainer
```
$ sudo sh install-portainer.sh
```
> Install Mergerfs NOTE: for Debian 9 and 10 provided
```
$ sudo sh install-mergerfs-debian10.sh
```
> Install Rclone
```
$ sudo sh install-rclone.sh
```

# Configure Rclone

- Create your rclone.conf
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

[googledrive_encrypted]
type = crypt
remote = gdrive:crypt
filename_encryption = standard
directory_name_encryption = true
password = **********
password2 = **********
```

## Rclone Mount Script

> Configure the <strong>cloudstorage_mount</strong> script. You only need to modify the "CONFIGURE" section

```
# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="vpsshare" # VPS share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # VPS share location
```

## Rclone Unmount Script

> Configure the <strong>cloudstorage_unmount</strong> script. You only need to modify the "CONFIGURE" section

```
# CONFIGURE
media="vpsshare" # VPS share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # VPS share location
```

## Rclone Upload Script

> Configure the <strong>cloudstorage_upload</strong> script. You only need to modify the "CONFIGURE" section

```
# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="vpsshare" # VPS share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # VPS share location
uploadlimit="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)
```

## Support



## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
