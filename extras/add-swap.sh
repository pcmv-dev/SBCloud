#!/bin/bash
# Author: SenpaiBox
# URL: https://github.com/SenpaiBox/CloudStorage
# Description: This script will add a swap partition

if [ `whoami` != root ]; then
    echo "Warning! Please run as sudo/root"
    echo "Ex: sudo sh add-swap.sh"
    exit
fi
grep -q "swapfile" /etc/fstab
grep -q "swap.img" /etc/fstab
if [ $? -ne 0 ]; then
  echo "Swapfile not found."
  echo "Enter in M|G ex: 512M or 2G"
  read -p "Enter your Swapfile size: " swapsize </dev/tty
  fallocate -l ${swapsize} /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo "/swapfile none swap defaults 0 0" >> /etc/fstab
else
  echo "Swap found. No changes made"
fi

df -h
cat /proc/swaps
cat /proc/meminfo | grep Swap
