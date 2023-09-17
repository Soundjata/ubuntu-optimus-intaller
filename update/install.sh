#!/bin/bash


if [ -d /etc/optimus/.git ]
then
    echo_red "optimus-installer ne peut pas être mis à jour lorsque le serveur est en mode développement. Utilisez GIT pour cette tâche"
else
    cd /
    rm -R /etc/optimus
    mkdir /etc/optimus
    git clone https://git.cybertron.fr/optimus/optimus-installer /etc/optimus
    chmod +x /etc/optimus/menu.sh
    source /etc/optimus/menu.sh
fi
