#!/bin/bash
source /etc/os-release

while getopts m:g:d:a:c:s:-: option
do
  if [ "$option" = "-" ]
  then
    option="${OPTARG%%=*}"
    OPTARG="${OPTARG#$option}"
    OPTARG="${OPTARG#=}"
  fi
  case "$option" in
    m | mode)
      MODE=$OPTARG
    ;;
    g | generate)
      sed -i 's/UUID=/UUID='$(</dev/urandom tr -dc A-Z0-9 | head -c 16)'/g' /root/.optimus
      sed -i 's/AES_KEY=/AES_KEY='$(</dev/urandom tr -dc A-Za-z0-9 | head -c 16)'/g' /root/.optimus
    ;;
    d | domain)
      sed -i 's/DOMAIN=/DOMAIN='$OPTARG'/g' /root/.optimus
    ;;
    a | app-key)
      sed -i 's/OVH_APP_KEY=/OVH_APP_KEY='$OPTARG'/g' /root/.optimus
    ;;
    c | consumer-key)
      sed -i 's/OVH_CONSUMER_KEY=/OVH_CONSUMER_KEY='$OPTARG'/g' /root/.optimus
    ;;
    s | secret-key)
      sed -i 's/OVH_SECRET_KEY=/OVH_SECRET_KEY='$OPTARG'/g' /root/.optimus
    ;;
    ??* )          
      echo "Unknown option --$option"
      exit 2 
    ;;
    ? )            
      echo "Unknown option -$option"
      exit 2 
    ;;
  esac
done

if [ "$MODE" = 'json' ]; then echo '{"code":200, "message":"MISE EN ROUTE DU SYSTEME OPTIMUS", "color":"blue","operation":"optimus-installer", "progress":0}'; fi
if [ "$MODE" = 'json' ]; then echo '{"code":200, "message":"Generation des locales", "color":"magenta","operation":"optimus-installer", "progress":15}'; fi
sudo sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
sudo sed -i 's/^# *\(fr_FR.UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen

if [ "$MODE" = 'json' ]; then echo '{"code":200, "message":"Mise à jour du dépôt", "color":"magenta","operation":"optimus-installer", "progress":30}'; fi
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes update

if [ "$MODE" = 'json' ]; then echo '{"code":200, "message":"Suppression de paquets inutiles", "color":"magenta","operation":"optimus-installer", "progress":40}'; fi
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes remove cryptsetup-initramfs

if [ "$MODE" = 'json' ]; then echo '{"code":200, "message":"Installation de git, unzip, zip, sudo et jq", "color":"magenta","operation":"optimus-installer", "progress":50}'; fi
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes install git unzip zip sudo jq

if [ "$MODE" = 'json' ]; then echo '{"code":200, "message":"Clonage du dépôt git", "color":"magenta","operation":"optimus-installer", "progress":70}'; fi
if [ -d "/etc/optimus" ]; then sudo rm -R /etc/optimus; fi
sudo mkdir /etc/optimus
sudo git clone https://git.cybertron.fr/optimus/optimus-installer /etc/optimus
sudo chmod +x /etc/optimus/menu.sh
sudo chown $ID:$ID -R /etc/optimus

if [ "$MODE" = 'json' ]; then echo '{"code":200, "message":"Synchronisation du serveur sur la zone Europe/Paris", "color":"magenta","operation":"optimus-installer", "progress":80}'; fi
sudo timedatectl set-timezone Europe/Paris

# CREATION D'UN SWAPFILE DE 2GO
# if [[ $(sudo /usr/sbin/swapon -s) != *"/var/swap.img"* ]]
# then
#   sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
#   sudo chmod 600 /var/swap.img
#   sudo mkswap /var/swap.img
#   sudo swapon /var/swap.img
#   sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
# fi

if [ "$MODE" = 'json' ]; then echo '{"code":200, "message":"Création d un alias pour la commande optimus", "color":"magenta","operation":"optimus-installer", "progress":90}'; fi
if ! grep -q "alias optimus" /home/debian/.bashrc
then
  echo "alias optimus='sudo bash /etc/optimus/menu.sh'" >> /home/debian/.bashrc
fi

if [ "$MODE" = 'json' ]; then echo '{"code":200, "message":"Installation réussie", "color":"green","operation":"optimus-installer", "progress":100}'; fi
