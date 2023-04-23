#!/bin/bash
sudo sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
sudo sed -i 's/^# *\(fr_FR.UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen

DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes update
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes remove cryptsetup-initramfs
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes install git unzip zip sudo jq

# CLONAGE DU DEPOT OPTIMUS INSTALLER
if [ -d "/etc/optimus-installer" ]; then sudo rm -R /etc/optimus-installer; fi
sudo mkdir /etc/optimus-installer
sudo git clone https://git.cybertron.fr/optimus/optimus-installer /etc/optimus-installer
sudo chmod +x /etc/optimus-installer/menu.sh

sudo timedatectl set-timezone Europe/Paris

# CREATION D'UN SWAPFILE DE 2GO
if [[ $(sudo /usr/sbin/swapon -s) != *"/var/swap.img"* ]]
then
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo chmod 600 /var/swap.img
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
fi

# ALIAS PERMETTANT DE LANCER LE MENU EN TAPPANT "optimus-installer"
if ! grep -q "alias optimus" /home/debian/.bashrc
then
  echo "alias optimus='sudo bash /etc/optimus-installer/menu.sh'" >> /home/debian/.bashrc
fi

# LANCEMENT DU MENU optimus-installer
sudo /etc/optimus-installer/menu.sh