#!/bin/bash
DEVNAME=$1
echo $(sgdisk -p /dev/${DEVNAME} | grep "Disk identifier (GUID):" | cut -d' ' -f4) "/dev/${DEVNAME}"
for p in `sgdisk --print /dev/${DEVNAME} | tail -n +10 | awk '{print $1}'`
do
	echo $(sgdisk -i ${p} /dev/${DEVNAME} | grep "Partition unique GUID:" | cut -d' ' -f4) "/dev/${DEVNAME}${p}" $(sgdisk -i ${p} /dev/${DEVNAME} | grep "Partition name:" | cut -d' ' -f3-) 
done
