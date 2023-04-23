#!/bin/bash
if [ ! -e /dev/mapper/crypt$PART_TO_ENCRYPT ]
then
	mkdir -p /root/tmpramfs
	mount ramfs /root/tmpramfs/ -t ramfs
	wget -qO /root/tmpramfs/keyfile_encrypted https://decrypt.optimus-avocats.fr/${UUID}_keyfile
	openssl rsautl -decrypt -inkey /root/private.pem -in /root/tmpramfs/keyfile_encrypted | /sbin/cryptsetup luksOpen /dev/$PART_TO_ENCRYPT crypt$PART_TO_ENCRYPT
	umount /root/tmpramfs
	rmdir /root/tmpramfs
	mount /dev/mapper/crypt$PART_TO_ENCRYPT /srv
	sleep 0.5

	if [ -d /srv/vhosts ]
	then
		systemctl restart incron
		systemctl restart nginx
	fi

	if [ -d /srv/optimus ]
	then
		docker start $(docker ps -a -q)
	fi
fi

if mountpoint -q /srv
then
	exit 0
else
	exit 1
fi