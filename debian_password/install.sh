#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "MODIFICATION DU MOT DE PASSE PAR DEFAUT" "blue" 200 "debian_password" 0

output $OUTPUT_MODE "Génération d'un nouveau mot de passe sécurisé" "magenta" 200 "debian_password" 33
DEBIAN_PASSWORD=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 16)
update_conf DEBIAN_PASSWORD $DEBIAN_PASSWORD

output $OUTPUT_MODE "Activation du nouveau mot de passe" "magenta" 200 "debian_password" 66
source /etc/os-release
echo "$ID:$DEBIAN_PASSWORD" | chpasswd $ID

output $OUTPUT_MODE "Le mot de passe a été modifié avec succès" "green" 200 "debian_password" 100