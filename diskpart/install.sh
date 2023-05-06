#!/bin/bash
source /etc/optimus/functions.sh
if [ -z $MODULE_DISKPART ]; then require MODULE_DISKPART yesno "Voulez-vous créer une nouvelle partition pour accueillir vos données ?"; source /root/.optimus; fi
source /root/.optimus


if [ $MODULE_DISKPART = "Y" ]
then

  echo
  echo_green "==== CREATION D'UNE NOUVELLE PARTITION ===="

  if [ -z $DISKPART_DISK_TO_PART ]
  then
    if [ -e /dev/nvme0n1 ]
    then
      update_conf DISKPART_DISK_TO_PART nvme0n1
      update_conf PART_TO_ENCRYPT nvme0n1p2
      source /root/.optimus
    elif [ -e /dev/sdb ]
    then
      update_conf DISKPART_DISK_TO_PART sdb
      update_conf PART_TO_ENCRYPT sdb
      source /root/.optimus
	elif [ -e /dev/sda ]
    then
      update_conf DISKPART_DISK_TO_PART sda
      update_conf PART_TO_ENCRYPT sda2
      source /root/.optimus
    else
      require DISKPART_DISK_TO_PART string "Veuillez indiquer sur quel disque se trouve la partition à partitionner :";
      require PART_TO_ENCRYPT string "Veuillez indiquer le nom de la nouvelle partition a créér :";
      source /root/.optimus
    fi
  fi

  if [ -e /dev/$DISKPART_DISK_TO_PART ] && [ ! -e /dev/$PART_TO_ENCRYPT ]
  then
    FREESPACE=$(/usr/sbin/sfdisk --list-free --quiet /dev/$DISKPART_DISK_TO_PART | grep -v "Size" |  awk '{print $NF}')
    FIRSTSECTOR=$(/usr/sbin/sfdisk --list-free --quiet /dev/$DISKPART_DISK_TO_PART | grep -v "Size" |  awk '{print $1}')

    if [ ! -z "$FREESPACE" ]
    then
      require DISKPART_USE_FREESPACE yesno "Souhaitez vous utiliser les $FREESPACE non partitionnés de $DISKPART_DISK_TO_PART";
      source /root/.optimus
      if [ $DISKPART_USE_FREESPACE = "Y" ]
      then
        echo $FIRSTSECTOR | /usr/sbin/sfdisk /dev/$PART_TO_ENCRYPT --append --force
        /usr/sbin/mkfs.ext4 /dev/$PART_TO_ENCRYPT
        mount /dev/$PART_TO_ENCRYPT /srv
      fi
    else
      echo_red "!! ATTENTION !!"
      echo_red "CETTE OPERATION EST RISQUEE"
      echo_red "ELLE PEUT CORROMPRE LE DISQUE ET LE SYSTEME"
      echo_red "IL N'EST RECOMMANDE DE LA LANCER QUE SUR UN SYSTEME VIERGE DE TOUTES DONNEES"
      echo

      require DISKPART_RESIZE_PARTITION yesno "Souhaitez vous redimensionner le disque $DISKPART_DISK_TO_PART ?";
      source /root/.optimus
      if [ $DISKPART_RESIZE_PARTITION = "Y" ]
      then
        echo_magenta "Mise en place des scripts de partitionnement..."
        verbose cp /etc/optimus/diskpart/resizefs_hook /etc/initramfs-tools/hooks/resizefs_hook
        verbose chmod +x /etc/initramfs-tools/hooks/resizefs_hook
        . /etc/os-release
        if [ $VERSION_ID == 10 ]
        then
          START_SECTOR=2048
        elif [ $VERSION_ID == 11 ]
        then
          START_SECTOR=262144
        fi
        envsubst '${START_SECTOR}' < /etc/optimus/diskpart/resizefs > /etc/initramfs-tools/scripts/local-premount/resizefs
        verbose chmod +x /etc/initramfs-tools/scripts/local-premount/resizefs
        verbose cp /etc/optimus/diskpart/rc.local /etc/rc.local
        verbose chmod +x /etc/rc.local
        sleep 0.5

        echo_magenta "Mise à jour du module INITRAMFS..."
        verbose apt-get remove -qq cryptsetup-initramfs
        verbose update-initramfs -u

        echo
        echo_red "Un redémarrage est nécessaire pour finaliser le partitionnement"
        echo_red "APPUYER SUR [ENTREE] POUR CONTINUER"
        read -p ""
        reboot
      fi
    fi
  else
    echo_magenta "La partition /dev/$PART_TO_ENCRYPT existe déjà"
  fi

fi
