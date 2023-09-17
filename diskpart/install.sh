#!/bin/bash
source /etc/optimus/functions.sh
source /root/.optimus

output $OUTPUT_MODE 
output $OUTPUT_MODE "CREATION D'UNE NOUVELLE PARTITION" 'blue' 200 'diskpart' 0

if [ -z $DISKPART_DISK_TO_PART ] || [ -z $PART_TO_ENCRYPT ]
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

output $OUTPUT_MODE "Disque sélectionné : $PART_TO_ENCRYPT" "magenta" 200 "diskpart" 25

if [ -e /dev/$DISKPART_DISK_TO_PART ] && [ ! -e /dev/$PART_TO_ENCRYPT ]
then
  FREESPACE=$(/usr/sbin/sfdisk --list-free --quiet /dev/$DISKPART_DISK_TO_PART | grep -v "Size" |  awk '{print $NF}')
  FIRSTSECTOR=$(/usr/sbin/sfdisk --list-free --quiet /dev/$DISKPART_DISK_TO_PART | grep -v "Size" |  awk '{print $1}')

  if [ ! -z "$FREESPACE" ]
  then
    require DISKPART_USE_FREESPACE yesno "Souhaitez vous utiliser les $FREESPACE non partitionnés de $DISKPART_DISK_TO_PART";
    source /root/.optimus
    if [ "$DISKPART_USE_FREESPACE" == "Y" ]
    then
      echo $FIRSTSECTOR | /usr/sbin/sfdisk /dev/$PART_TO_ENCRYPT --append --force
      /usr/sbin/mkfs.ext4 /dev/$PART_TO_ENCRYPT
      mount /dev/$PART_TO_ENCRYPT /srv
    fi
  else
      
    if [ "$OUTPUT_MODE" == "console" ]
    then
      echo_red "!! ATTENTION !!"
      echo_red "CETTE OPERATION EST RISQUEE"
      echo_red "ELLE PEUT CORROMPRE LE DISQUE ET LE SYSTEME"
      echo_red "IL N'EST RECOMMANDE DE LA LANCER QUE SUR UN SYSTEME VIERGE DE TOUTES DONNEES"
      echo
    fi

    if [ "$OUTPUT_MODE" == "console" ]
    then
      require DISKPART_RESIZE_PARTITION yesno "Souhaitez vous redimensionner le disque $DISKPART_DISK_TO_PART ?";
      source /root/.optimus
    fi

    if [ "$DISKPART_RESIZE_PARTITION" == "Y" ] || [ "$OUTPUT_MODE" == 'json' ]
    then
      output $OUTPUT_MODE "Mise en place des scripts de partitionnement..." "magenta" 200 "diskpart" 50
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

      output $OUTPUT_MODE "Mise à jour du module INITRAMFS..." "magenta" 200 "diskpart" 75
      verbose apt-get remove -qq cryptsetup-initramfs
      verbose update-initramfs -u

      if [ "$OUTPUT_MODE" == "console" ]
      then
        echo
        echo_red "Un redémarrage est nécessaire pour finaliser le partitionnement"
        echo_red "APPUYER SUR [ENTREE] POUR CONTINUER"
        read -p ""
        reboot
		exit
      else
        output $OUTPUT_MODE "Redémarrage..." "magenta" 200 "diskpart" 90
        reboot
		exit
      fi
    fi
  fi
else
  output $OUTPUT_MODE "La partition /dev/$PART_TO_ENCRYPT existe déjà" "red" 200 "diskpart" 100
fi
