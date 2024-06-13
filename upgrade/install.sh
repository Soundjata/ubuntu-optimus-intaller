#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE 
output $OUTPUT_MODE "MISE A JOUR DE UBUNTU" "blue" 200 "upgrade" 0

output $OUTPUT_MODE "Update" "magenta" 200 "upgrade" 25
UBUNTU_FRONTEND=noninteractive verbose apt-get -qq --yes --allow-releaseinfo-change update

output $OUTPUT_MODE "Upgrade" "magenta" 200 "upgrade" 50
UBUNTU_FRONTEND=noninteractive verbose apt-get -qq --yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

output $OUTPUT_MODE "Dist-Upgrade" "magenta" 200 "upgrade" 75
UBUNTU_FRONTEND=noninteractive verbose apt-get -qq --yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

update_conf LAST_UPGRADE $(date +'%Y%m%d')
output $OUTPUT_MODE "Mise à jour terminée avec succès" "green" 200 "upgrade" 100