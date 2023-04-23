#!/bin/bash
source /etc/optimus-installer/functions.sh
if [ -z $MODULE_CRYPT ]; then require MODULE_CRYPT yesno "Voulez-vous chiffrer la partition qui stocke vos données ?"; source /root/.optimus-installer; fi
if [ -z $AUTODECRYPT ]; then require AUTODECRYPT yesno "Voulez-vous que la partition se déchiffre automatiquement au démarrage du serveur ?"; source /root/.optimus-installer; fi
if [ -z $PART_TO_ENCRYPT ]; then require PART_TO_ENCRYPT string "Veuillez indiquer le nom de la partition à encrypter :"; source /root/.optimus-installer; fi
if [ -z $UUID ] || [ $UUID = "auto" ]; then require UUID uuid "Veuillez choisir et renseigner un identifiant unique de 16 caractères [A-Z0-9]"; source /root/.optimus-installer; fi
source /root/.optimus-installer

if [ $MODULE_CRYPT = "Y" ]
then

  echo
  echo_green "==== CHIFFREMENT DU DISQUE ===="

  if lsblk -o NAME -n /dev/$PART_TO_ENCRYPT 2>/dev/null | grep -q $PART_TO_ENCRYPT && [ ! -e /dev/mapper/crypt${PART_TO_ENCRYPT} ]
  then

    echo_magenta "Installation des paquets requis"
    DEBIAN_FRONTEND=noninteractive apt-get -qq install keyboard-configuration &> /dev/null
    DEBIAN_FRONTEND=noninteractive apt-get -qq install cryptsetup cryptsetup-bin &> /dev/null
    verbose apt-get -qq install curl

    if mountpoint -q /srv
    then
      echo_magenta "Démontage de la partition /srv"
      verbose umount /srv
    fi

    echo_magenta "Création d'une clé de chiffrement"
    mkdir /root/tmpramfs
    mount ramfs /root/tmpramfs/ -t ramfs
    </dev/urandom tr -dc A-Za-z0-9 | head -c 256 > /root/tmpramfs/keyfile
    chmod 0400 /root/tmpramfs/keyfile
    openssl genrsa -out /root/private.pem 4096 &> /dev/null
    openssl rsa -in /root/private.pem -outform PEM -pubout -out /root/public.pem &> /dev/null
    openssl rsautl -encrypt -inkey /root/public.pem -pubin -in /root/tmpramfs/keyfile -out /root/tmpramfs/keyfile_encrypted &> /dev/null
    sleep 0.5

    echo_magenta "Envoi de la clé de chiffrement sur le serveur distant"
    curl -X POST -F "$UUID=@/root/tmpramfs/keyfile_encrypted" https://decrypt.optimus-avocats.fr/index.php

    echo_magenta "Activation du chiffrement sur la partition"
    openssl rsautl -decrypt -inkey /root/private.pem -in /root/tmpramfs/keyfile_encrypted | /sbin/cryptsetup --batch-mode luksFormat /dev/$PART_TO_ENCRYPT
    sleep 0.5

    echo_magenta "Ouverture de la partition chiffrée"
    openssl rsautl -decrypt -inkey /root/private.pem -in /root/tmpramfs/keyfile_encrypted | /sbin/cryptsetup luksOpen /dev/$PART_TO_ENCRYPT crypt$PART_TO_ENCRYPT
    sleep 0.5

    echo_magenta "Formattage de la partition chiffrée au format EXT4"
    /sbin/mkfs.ext4 /dev/mapper/crypt$PART_TO_ENCRYPT &> /dev/null
    sleep 0.5

    echo_magenta "Sauvegarde du header"
    verbose cryptsetup luksHeaderBackup /dev/$PART_TO_ENCRYPT --header-backup-file /root/headerbackup
    sleep 0.5

    echo_magenta "Montage de la partition dans /srv"
    mount /dev/mapper/crypt$PART_TO_ENCRYPT /srv
    umount /root/tmpramfs
    rmdir /root/tmpramfs

  else

    if ! lsblk -o NAME -n /dev/$PART_TO_ENCRYPT 2>/dev/null | grep -q $PART_TO_ENCRYPT
    then
      echo_red "Opération impossible : la partition /dev/$PART_TO_ENCRYPT n'existe pas"
    fi

    if [ -e /dev/mapper/crypt${PART_TO_ENCRYPT} ]
    then
      echo_red "Opération impossible : la partition est déjà chiffrée"
    fi
  fi
  
  if [ $AUTODECRYPT = "Y" ]
  then
    echo_magenta "Activation du service de décryptage"
    envsubst '${PART_TO_ENCRYPT} ${UUID}' < /etc/optimus-installer/crypt/decrypt.sh > /root/decrypt.sh
    verbose chmod 700 /root/decrypt.sh
    verbose cp /etc/optimus-installer/crypt/decrypt.service /etc/systemd/system/decrypt.service
    verbose systemctl daemon-reload
	verbose systemctl enable decrypt.service 2> /dev/null
  else
    echo_magenta "Désactivation du service de décryptage"
    verbose systemctl daemon-reload
	verbose systemctl disable decrypt.service 2> /dev/null
  fi
fi
