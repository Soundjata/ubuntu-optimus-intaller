#!/bin/bash
cd /
rm -R /etc/optimus
mkdir /etc/optimus

if [ -d /etc/docker ] && [ $( docker ps -a | grep optimus-devtools | wc -l ) -gt 0 ]
then
    echo_red "optimus-installer ne peut pas être mis à jour lorsque le serveur est en mode développement. Utilisez GIT pour cette tâche"
else
    git clone https://git.cybertron.fr/optimus/optimus-installer /etc/optimus
fi

chmod +x /etc/optimus/menu.sh
source /etc/optimus/menu.sh
