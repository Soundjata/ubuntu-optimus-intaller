#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "OUVERTURE D'UN ACCES SSH POUR LE SUPPORT CYBERTRON" "blue" 200 "cybertron_ssh_key" 0

CYBERTRON_PUBLIC_KEY=$(cat /etc/optimus/cybertron_ssh_key/prime.pub)
if grep -q "$CYBERTRON_PUBLIC_KEY" /home/debian/.ssh/authorized_keys
then
	output $OUTPUT_MODE "La clé est déjà installée" "red" 200 "cybertron_ssh_key" 100
else
	output $OUTPUT_MODE "Ajout de la clé publique de support CYBERTRON" "magenta" 200 "cybertron_ssh_key" 50
	echo $CYBERTRON_PUBLIC_KEY >> /home/debian/.ssh/authorized_keys
	output $OUTPUT_MODE "La clé a été ajoutée avec succès" "green" 200 "cybertron_ssh_key" 100
fi

