#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE 'Update' 'magenta' 200 'upgrade' 25
DEBIAN_FRONTEND=noninteractive verbose apt-get -qq -y --allow-releaseinfo-change update

output $OUTPUT_MODE 'Upgrade' 'magenta' 200 'upgrade' 50
DEBIAN_FRONTEND=noninteractive verbose apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

output $OUTPUT_MODE 'Dist-Upgrade' 'magenta' 200 'upgrade' 75
DEBIAN_FRONTEND=noninteractive verbose apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade

update_conf LAST_UPGRADE $(date +'%Y%m%d')
output $OUTPUT_MODE 'Upgrade completed' 'magenta' 200 'upgrade' 100