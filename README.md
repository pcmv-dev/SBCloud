
<center>
<h1 align="center">VPSCloudStorage</h1>
<h4 align="center">Rclone mount your GoogleDrive to upload from your VPS machine</h4>
<h5 align="Center"><strong>02/18/2020 - Version 0.03</strong>
</center>

# Info

Use these scripts to help you upload from your VPS. The idea is to setup Docker,Portainer, and NZBget/ruTorrent to download your media and then have Rclone upload it to your GoogleDrive to be able to watch from your Plex/Emby Server. Why is this useful you might ask? well check out the pros and cons below.

### Pros
- You have slow download/upload, so you use your VPS that has fast Gigabit speeds
- Bandwidth is freed up on your end
- You can upload media, quicker

### Cons
- Extra cost, to pay for a VPS
- Working with a terminal

### Prerequisites

Install both plugins from "Community Applications Store"
NOTE: These are meant for UNRAID
- Rclone-Beta (Beta is needed) [INSTALL](https://forums.unraid.net/topic/51633-plugin-rclone/)
- CA User Scripts [INSTALL](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/)

## Configure Rclone Remotes

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

- Configure the <strong>cloudstorage_mount</strong> script. You only need to modify the "CONFIGURE" section

```
# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="unraidshare" # Unraid share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # Unraid share location
```
- Set a schedule to run the script 10min, hourly, or when you would like to begin upload
- [Crontab Calculator](https://corntab.com/)

## Rclone Unmount Script

- Configure the <strong>cloudstorage_unmount</strong> script. You only need to modify the "CONFIGURE" section

```
# CONFIGURE
media="unraidshare" # Unraid share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # Unraid share location
```
- Set a schedule to run at array startup. Note: You can manually trigger the unmount if needed

## Rclone Upload Script

- Configure the <strong>cloudstorage_upload</strong> script. You only need to modify the "CONFIGURE" section

```
# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="unraidshare" # Unraid share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # Unraid share location
uploadlimit="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)
```
- Set a schedule to run the script whenever you feel is a good time. For me it is midnight (0 00 * * *)

## Changelog

- v1.2 - Code revision and less configuration
- v1.1 - Integrated mountcheck and Logging changes
- v1.0 - Initial Scripts

## Support

I am only a novice when it comes to scripting so for help and support please visit the forum for help

- [Guide: How To Use Rclone To Mount Cloud Drives And Play Files](https://forums.unraid.net/topic/75436-guide-how-to-use-rclone-to-mount-cloud-drives-and-play-files/)
- [Original Scripts](https://github.com/BinsonBuzz/unraid_rclone_mount)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* BinsonBuzz for his super useful scripts :clap:
