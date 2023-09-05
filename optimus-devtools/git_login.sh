#!/bin/bash
source /etc/optimus/functions.sh

echo
echo_magenta "Connexion au registre de conteneurs https://git.cybertron.fr:5050"
docker login https://git.cybertron.fr:5050

echo
echo_magenta "Génération d'une clé développeur ED25519 pour l'utilisateur debian"
if [ ! -f /home/debian/.ssh/optimusdev ]
then
    ssh-keygen -t ed25519 -f "/home/debian/.ssh/optimusdev" -C "$DOMAIN"
    chmod debian:debian /home/debian/.ssh/optimusdev
    chmod debian:debian /home/debian/.ssh/optimusdev.pub
fi
echo
echo_green "Vous trouverez ci-dessous la clé publique de ce serveur à copier sur https://git.cybertron.fr :"
echo
echo_yellow "$(cat /home/debian/.ssh/optimusdev.pub)"
echo

read -p "Appuyez sur [ENTREE] pour continuer..."