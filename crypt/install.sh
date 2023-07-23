#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE 
output $OUTPUT_MODE "CHIFFREMENT DU DISQUE" "blue" 200 "crypt" 0

if ! lsblk -o NAME -n /dev/$PART_TO_ENCRYPT 2>/dev/null | grep -q $PART_TO_ENCRYPT
then
  output $OUTPUT_MODE "Opération impossible : la partition /dev/$PART_TO_ENCRYPT n'existe pas" "red" 200 "crypt" 100
  exit
fi

if [ -e /dev/mapper/crypt${PART_TO_ENCRYPT} ]
then
  output $OUTPUT_MODE "Opération impossible : la partition est déjà chiffrée" "red" 200 "crypt" 100
  exit
fi



if lsblk -o NAME -n /dev/$PART_TO_ENCRYPT 2>/dev/null | grep -q $PART_TO_ENCRYPT && [ ! -e /dev/mapper/crypt${PART_TO_ENCRYPT} ]
then

  output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "crypt" 10
  DEBIAN_FRONTEND=noninteractive apt-get -qq install keyboard-configuration &> /dev/null
  DEBIAN_FRONTEND=noninteractive apt-get -qq install cryptsetup cryptsetup-bin &> /dev/null
  verbose apt-get -qq install curl

  if mountpoint -q /srv
  then
    output $OUTPUT_MODE "Démontage de la partition /srv" "magenta" 200 "crypt" 20
    verbose umount /srv
  fi

  output $OUTPUT_MODE "Création d'une clé de chiffrement" "magenta" 200 "crypt" 30
  mkdir /root/tmpramfs
  mount ramfs /root/tmpramfs/ -t ramfs
  </dev/urandom tr -dc A-Za-z0-9 | head -c 256 > /root/tmpramfs/keyfile
  chmod 0400 /root/tmpramfs/keyfile
  openssl genrsa -out /root/private.pem 4096 &> /dev/null
  openssl rsa -in /root/private.pem -outform PEM -pubout -out /root/public.pem &> /dev/null
  openssl rsautl -encrypt -inkey /root/public.pem -pubin -in /root/tmpramfs/keyfile -out /root/tmpramfs/keyfile_encrypted &> /dev/null
  sleep 0.5

  output $OUTPUT_MODE "Envoi de la clé de chiffrement sur le serveur distant" "magenta" 200 "crypt" 40
  curl -X POST -F "$UUID=@/root/tmpramfs/keyfile_encrypted" https://decrypt.optimus-avocats.fr/index.php

  output $OUTPUT_MODE "Activation du chiffrement sur la partition" "magenta" 200 "crypt" 50
  openssl rsautl -decrypt -inkey /root/private.pem -in /root/tmpramfs/keyfile_encrypted | /sbin/cryptsetup --batch-mode luksFormat /dev/$PART_TO_ENCRYPT
  sleep 0.5

  output $OUTPUT_MODE "Ouverture de la partition chiffrée" "magenta" 200 "crypt" 60
  openssl rsautl -decrypt -inkey /root/private.pem -in /root/tmpramfs/keyfile_encrypted | /sbin/cryptsetup luksOpen /dev/$PART_TO_ENCRYPT crypt$PART_TO_ENCRYPT
  sleep 0.5

  output $OUTPUT_MODE "Formattage de la partition chiffrée au format EXT4" "crypt" 200 "crypt" 70
  /sbin/mkfs.ext4 /dev/mapper/crypt$PART_TO_ENCRYPT &> /dev/null
  sleep 0.5

  output $OUTPUT_MODE "Sauvegarde du header" "magenta" 200 "crypt" 80
  verbose cryptsetup luksHeaderBackup /dev/$PART_TO_ENCRYPT --header-backup-file /root/headerbackup
  sleep 0.5

  output $OUTPUT_MODE "Montage de la partition dans /srv" "crypt" 200 "crypt" 90
  mount /dev/mapper/crypt$PART_TO_ENCRYPT /srv
  umount /root/tmpramfs
  rmdir /root/tmpramfs

fi

output $OUTPUT_MODE "Activation du service de décryptage" "magenta" 200 "crypt" 100
envsubst '${PART_TO_ENCRYPT} ${UUID}' < /etc/optimus/crypt/decrypt.sh > /root/decrypt.sh
verbose chmod 700 /root/decrypt.sh
verbose cp /etc/optimus/crypt/decrypt.service /etc/systemd/system/decrypt.service
verbose systemctl daemon-reload
verbose systemctl enable decrypt.service 2> /dev/null

output $OUTPUT_MODE "Chiffrement activé" "green" 200 "crypt" 100

#echo_magenta "Désactivation du service de décryptage"
#    verbose systemctl daemon-reload
#	verbose systemctl disable decrypt.service 2> /dev/null