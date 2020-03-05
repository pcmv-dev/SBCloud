#!/bin/bash
# By default, Docker recommends using a value of vm.swappiness=0 for Docker environments, which prevents swapping except
# in the case of an OOM (OutOfMemory) condition. All nodes must set vm.overcommit_memory=1, which tells the kernel to always
# allow memory allocations until there is no truly memory.
# If vm.swappiness is set to a value higher than 0, you might notice that only swap memory is being used on the node even
# though host memory was available.

vmswap="$(grep -oP '[0-9]' /proc/sys/vm/swappiness | tr -d '"')"
vmover="$(grep -oP '[0-9]' /proc/sys/vm/overcommit_memory | tr -d '"')"
if [ $vmswap != "0" ] | [ $vmover != "1" ]; then
    sudo sysctl vm.swappiness=0
    sudo sysctl vm.overcommit_memory=1
    echo '' >> /etc/sysctl.conf
    echo '# Docker Memory Tweak' >> /etc/sysctl.conf
    echo 'vm.swappiness=0' >> /etc/sysctl.conf
    echo 'vm.overcommit_memory=1' >> /etc/sysctl.conf
else
    echo "Docker Memory Tweak already applied"
    sudo sysctl -a | grep 'vm.swapp*\|vm.overcommit_memory*'
fi
exit