#!/bin/bash
# This script will add a swap partition

# Size of Swapfile
swapsize="512M"

# does the swap file already exist?
grep -q "swapfile" /etc/fstab

# if not then create it
if [ $? -ne 0 ]; then
  echo "Swapfile not found. Adding swapfile"
  fallocate -l ${swapsize} /swapfile
  sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo "/swapfile none swap defaults 0 0" >> /etc/fstab
else
  echo "Swap found. No changes made"
fi

# output results to terminal
df -h
cat /proc/swaps
cat /proc/meminfo | grep Swap
