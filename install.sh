#!/bin/bash
sudo sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
sudo sed -i 's/^# *\(fr_FR.UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen

DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes update
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes remove cryptsetup-initramfs
DEBIAN_FRONTEND=noninteractive sudo apt-get -qq --yes install git unzip zip sudo jq

# CLONAGE DU DEPOT OPTIMUS INSTALLER
if [ -d "/etc/optimus" ]; then sudo rm -R /etc/optimus; fi
sudo mkdir /etc/optimus
sudo git clone https://git.cybertron.fr/optimus/optimus-installer /etc/optimus
sudo chmod +x /etc/optimus/menu.sh

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

# ALIAS PERMETTANT DE LANCER LE MENU EN TAPPANT "optimus"
if ! grep -q "alias optimus" /home/debian/.bashrc
then
  echo "alias optimus='sudo bash /etc/optimus/menu.sh'" >> /home/debian/.bashrc
fi

# GENERATION DES VARIABLES PAR DEFAUT SI SOLLICITE AU PREMIER LANCEMENT
source /etc/optimus/functions.sh
while getopts g:d:a:c:s:-: option
do
  if [ "$option" = "-" ]
  then   # long option: reformulate OPT and OPTARG
    option="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#$option}"   # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi
  case "$option" in
    g | generate)
      update_conf UUID $(</dev/urandom tr -dc A-Z0-9 | head -c 16)
    ;;
    d | domain)
      echo $OPTARG
      update_conf DOMAIN $OPTARG
    ;;
    a | ovh-app-key)
      echo $OPTARG
      update_conf OVH_APP_KEY $OPTARG
    ;;
    c | ovh-consumer-key)
      echo $OPTARG
      update_conf OVH_CONSUMER_KEY $OPTARG
    ;;
    s | ovh-secret-key)
      echo $OPTARG
      update_conf OVH_SECRET_KEY $OPTARG
    ;;
    ??* )          
      echo "Unknown option --$option"
      exit 2 
    ;;  # bad long option
    ? )            
      echo "Unknown option -$option"
      exit 2 
    ;;  # bad short option (error reported via getopts)
  esac
done



source /etc/optimus/functions.sh
if [ ! -f /root/.optimus ]
then
  cp /etc/optimus/config.sh /root/.optimus

  if [ $1 = 'autogen' ]
  then
    update_conf UUID $(</dev/urandom tr -dc A-Z0-9 | head -c 16)
  fi
fi


# LECTURE DES VARIABLES PASSEES
while getopts ":autogen:domain:" opt; do
  case $opt in
    autogen)
      update_conf UUID $(</dev/urandom tr -dc A-Z0-9 | head -c 16)
    ;;
    domain) 
      update_conf DOMAIN $OPTARG
    ;;
    \?) echo "Option invalide -$OPTARG" >&2
        exit 1 ;;
    :) echo "L'option -$OPTARG nécessite un argument." >&2
       exit 1 ;;
  esac
done

if [ -z $2 ]
then
  update_conf DOMAIN $1
fi