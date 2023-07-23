#!/bin/bash
source /etc/optimus/functions.sh

echo_green "==== MISE A JOUR DE DEBIAN 10 VERS DEBIAN 11 ===="

. /etc/os-release
if [ $ID == 'debian' ] && [ $VERSION_ID == 11 ]
then
  sed -i 's/buster/bullseye/g' /etc/apt/sources.list
fi

echo_magenta "Update"
DEBIAN_FRONTEND=noninteractive verbose apt-get -qq -y --allow-releaseinfo-change update

echo_magenta "Upgrade"
DEBIAN_FRONTEND=noninteractive verbose apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

echo_magenta "Dist-Upgrade"
DEBIAN_FRONTEND=noninteractive verbose apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

update_conf LAST_UPGRADE $(date +'%Y%m%d')