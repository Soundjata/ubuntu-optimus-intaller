#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DU GESTIONNAIRE DE CONTENEURS DOCKER" "blue" 200 "docker" 0

output $OUTPUT_MODE "Création du groupe docker et ajout de l'utilisateur www-data" "magenta" 200 "docker" 20
verbose groupadd --gid 220 docker
verbose usermod -aG docker www-data
verbose usermod -aG docker debian
 
output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "docker" 35
verbose apt-get -qq install docker.io
  
output $OUTPUT_MODE "Activation du service" "magenta" 200 "docker" 50
verbose systemctl enable docker 2> /dev/null

output $OUTPUT_MODE "Changement des droits sur le socket DOCKER" "magenta" 200 "docker" 65
chown root:docker /var/run/docker.sock

output $OUTPUT_MODE "Création du réseau docker optimus" "magenta" 200 "docker" 80
verbose docker network create --subnet=172.20.0.0/16 optimus

output $OUTPUT_MODE "DOCKER a été installé avec succès" "green" 200 "docker" 100