#!/bin/bash
cd /
rm -R /etc/optimus
mkdir /etc/optimus
if [ $DEV == 1 ]
then
    git clone git@git.cybertron.fr/optimus/optimus-installer /etc/optimus
else
    git clone git@git.cybertron.fr/optimus/optimus-installer /etc/optimus
fi

chmod +x /etc/optimus/menu.sh
source /etc/optimus/menu.sh
