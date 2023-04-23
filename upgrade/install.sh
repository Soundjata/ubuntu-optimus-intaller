#!/bin/bash
source /etc/optimus-installer/functions.sh
if [ -z $MODULE_UPGRADE ]; then require MODULE_UPGRADE yesno "Voulez vous mettre à jour le système -> update/upgrade/dist-upgrade ?"; source /root/.optimus-installer; fi
source /root/.optimus-installer

if [ $MODULE_UPGRADE = "Y" ]
then
  echo_green "==== MISE A JOUR DU SYSTEME ===="

  . /etc/os-release
  if [ $ID == 'debian' ] && [ $VERSION_ID == 10 ]
  then
    echo_green "Vous exécutez DEBIAN 10. Souhaitez-vous mettre à jour vers DEBIAN 11 ?"
    while [ -z "$reponse" ]
    do
      read -p "(o)ui / (n)on ? " -n 1 -e reponse
      if [[ $reponse =~ ^[YyOo]$ ]]
      then
        sed -i 's/buster/bullseye/g' /etc/apt/sources.list
        sed -i 's/bullseye\/updates/bullseye-security/g' /etc/apt/sources.list
      fi
    done
  fi

  echo_magenta "Update"
  DEBIAN_FRONTEND=noninteractive verbose apt-get -qq -y --allow-releaseinfo-change update

  echo_magenta "Upgrade"
  DEBIAN_FRONTEND=noninteractive verbose apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

  echo_magenta "Dist-Upgrade"
  DEBIAN_FRONTEND=noninteractive verbose apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

  update_conf LAST_UPGRADE $(date +'%Y%m%d')
fi
