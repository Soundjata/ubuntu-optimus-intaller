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
if [ ! -z $DISKPART_DISK_TO_PART ] && [ ! -z $PART_TO_ENCRYPT ] && [ -e /dev/$DISKPART_DISK_TO_PART ] && [ -e /dev/$PART_TO_ENCRYPT ]
then
	output $OUTPUT_MODE "status" "green" 200 "diskpart" 100
fi

if [ -e /dev/mapper/crypt${PART_TO_ENCRYPT} ]
then
	output $OUTPUT_MODE "status" "green" 200 "crypt" 100
fi

if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]
then
	output $OUTPUT_MODE "status" "green" 200 "letsencrypt_ovh" 100
fi

if [ -d /etc/nginx ]
then
	output $OUTPUT_MODE "status" "green" 200 "nginx" 100
fi

if [ -d /etc/docker ]
then
	output $OUTPUT_MODE "status" "green" 200 "docker" 100
fi

if [ $( docker ps -a | grep optimus-databases | wc -l ) -gt 0 ]
then
	output $OUTPUT_MODE "status" "green" 200 "optimus-databases" 100
fi

if [ $( docker ps -a | grep optimus-base | wc -l ) -gt 0 ]
then
	output $OUTPUT_MODE "status" "green" 200 "optimus-base" 100
fi

if [ -f /etc/ufw/applications.d/ufw-webserver ]
then
	output $OUTPUT_MODE "status" "green" 200 "firewall" 100
fi

if [ -d /etc/fail2ban ]
then
	output $OUTPUT_MODE "status" "green" 200 "fail2ban" 100
fi

if grep -q "Port 7822" /etc/ssh/sshd_config
then
	output $OUTPUT_MODE "status" "green" 200 "ssh_port_change" 100
fi

if [ ! -z $DEBIAN_PASSWORD ]
then
	output $OUTPUT_MODE "status" "green" 200 "debian_password" 100
fi

if grep -q "auth required pam_google_authenticator.so" /etc/pam.d/sshd
then
	output $OUTPUT_MODE "status" "green" 200 "2fa" 100
fi

CYBERTRON_PUBLIC_KEY=$(cat /etc/optimus/cybertron_ssh_key/prime.pub)
if grep -q "$CYBERTRON_PUBLIC_KEY" /home/debian/.ssh/authorized_keys
then
	output $OUTPUT_MODE "status" "green" 200 "cybertron_ssh_key" 100
fi 

if [ -f /etc/knockd.conf ]
then
	output $OUTPUT_MODE "status" "green" 200 "port_knocking" 100
fi 

