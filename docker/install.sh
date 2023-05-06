#!/bin/bash
source /etc/optimus/functions.sh
if [ -z $MODULE_DOCKER ]; then require MODULE_DOCKER yesno "Souhaitez vous installer le gestionnaire de conteneurs DOCKER ?"; source /root/.optimus; fi
source /root/.optimus

if [ $MODULE_DOCKER = "Y" ]
then
  echo
  echo_green "==== INSTALLATION DU GESTIONNAIRE DE CONTENEURS DOCKER ===="

  echo_magenta "Création du groupe docker et ajout de l'utilisateur www-data"
  verbose groupadd --gid 220 docker
  verbose usermod -aG docker www-data
  verbose usermod -aG docker debian
  
  echo_magenta "Installation des paquets"
  verbose apt-get -qq install docker.io
  
  echo_magenta "Activation du service"
  verbose systemctl enable docker 2> /dev/null
  
  echo_magenta "Changement des droits sur le socket DOCKER"
  chown root:docker /var/run/docker.sock

  echo_magenta "Création du réseau docker optimus"
  verbose docker network create --subnet=172.20.0.0/16 optimus
fi