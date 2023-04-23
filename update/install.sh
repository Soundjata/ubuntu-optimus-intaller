#!/bin/bash
cd /
rm -R /etc/optimus-installer
mkdir /etc/optimus-installer
if [ $DEV == 1 ]
then
    git clone --branch dev https://git.cybertron.fr/optimus/optimus-installer /etc/optimus-installer
else
    git clone https://git.cybertron.fr/optimus/optimus-installer /etc/optimus-installer
fi

chmod +x /etc/optimus-installer/menu.sh
source /etc/optimus-installer/menu.sh
