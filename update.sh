#!/usr/bin/env bash

# CHECK DISK FREE SPACE
required_disk_free=200000
disk_free=$(df -l | grep '/dev/root' | awk '{print $4}')
echo "FREE DISK SPACE: $disk_free M"
if [ "$disk_free" -lt "$required_disk_free" ]; then
  echo "error > NOT ENOUGH FREE DISK SPACE (200M REQUIRED)"
  exit
fi

# GET CURRENT VERSION
version=$(cat /home/we/version.txt)
echo "CURRENT VERSION: $version"

# CHECK FOR USB DISK UPDATE FILES, COPY IF VALID
disk_mount=$(lsblk -o mountpoint | grep media)
if [ ! -f "$disk_mount" ]; then
  echo "USB DISK PRESENT"
  from_disk=$(ls $disk_mount | grep norns | sed 's/.norns//' | sort -r | head -1)
  if [ "$from_disk" -gt "$version" ]; then
    echo "> COPYING FROM USB DISK"
    sudo cp -v $disk_mount/$from_disk.norns /home/we/update/
  fi
fi

# CHECK FOR LOCAL UPDATE FILES
local_update=$(ls /home/we/update | grep norns | sed 's/.norns//' | sort -r | head -1)
echo "LOCAL UPDATE VERSION: $local_update"
if [ -z "$local_update" ]; then
  echo "error > NO UPDATES"
  exit
fi
if [ "$version" -gt "$local_update" ]; then
  echo "error > OLD UPDATE, NOT APPLYING"
  echo "> REMOVING UPDATES"
  rm -rf /home/we/update/*
  exit
fi

# EXTRACT UPDATE
echo "> EXTRACTING UPDATE $local_update"
cd /home/we/update
tar xzvf $local_update.norns

# CHECK MD5
check=$(md5sum -c *.md5 | grep "OK")
if [ -z "$check" ]; then
  echo "error > MD5 FAILED. BAD UPDATE FILE."
  echo "> REMOVING UPDATES"
  rm -rf /home/we/update/*
  exit
fi

# RUN UPDATE
tar xzvf $local_update.tgz
echo "--------------------"
echo "> RUNNING $local_update/update.sh"
$local_update/update.sh

echo "--------------------"
echo "UPDATE COMPLETE"

# CLEANUP
echo "> REMOVING UPDATES"
rm -rf /home/we/update/*

# REBOOT
read -p "PRESS ENTER TO SHUTDOWN"
echo "SHUTTING DOWN"
sudo shutdown now
