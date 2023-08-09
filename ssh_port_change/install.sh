#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "REMPLACEMENT DU PORT SSH" "blue" 200 "ssh_port_change" 0

output $OUTPUT_MODE "Remplacement du port 22 par le port 7822" "magenta" 200 "ssh_port_change" 25
verbose sed -i 's/#Port 22/Port 7822/g' /etc/ssh/sshd_config

if [ $(which /sbin/ufw) ]
then
  output $OUTPUT_MODE "Ouverture du port 7822 dans le firewall" "magenta" 200 "ssh_port_change" 50
  verbose /sbin/ufw allow 7822
  output $OUTPUT_MODE "Fermeture du port 22 dans le firewall" "magenta" 200 "ssh_port_change" 75
  verbose /sbin/ufw deny 22
fi

output $OUTPUT_MODE "Le serveur SSH a été sécurisé avec succès" "green" 200 "ssh_port_change" 100