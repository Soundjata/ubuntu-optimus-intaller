#!/bin/bash
cd /
rm -R /etc/optimus
mkdir /etc/optimus

if [ -d /etc/docker ] && [ $( docker ps -a | grep optimus-devtools | wc -l ) -gt 0 ]
then
    su -c 'git clone --quiet git@git.cybertron.fr:optimus/optimus-installer.git /etc/optimus' debian
else
    git clone https://git.cybertron.fr/optimus/optimus-installer /etc/optimus
fi

chmod +x /etc/optimus/menu.sh
source /etc/optimus/menu.sh
