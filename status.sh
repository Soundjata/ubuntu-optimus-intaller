#!/bin/bash
source /etc/optimus/functions.sh

#OPTIMUS INSTALLER
output $OUTPUT_MODE "status" "green" 200 "optimus-installer" 100

#UPGRADE
if [ ! -z $LAST_UPGRADE ]
then 
    output $OUTPUT_MODE "status" "green" 200 "upgrade" 100
fi

#DISKPART
if [ -e /dev/$DISKPART_DISK_TO_PART ] && [ -e /dev/$PART_TO_ENCRYPT ]
then
    output $OUTPUT_MODE "status" "green" 200 "diskpart" 100
fi

if [ -e /dev/mapper/crypt${PART_TO_ENCRYPT} ]
then
    output $OUTPUT_MODE "status" "green" 200 "crypt" 100
fi