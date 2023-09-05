#!/bin/bash
source /etc/optimus/functions.sh

echo
echo_cyan "Connexion au registre de conteneurs https://git.cybertron.fr:5050"
docker login https://git.cybertron.fr:5050

echo
echo
echo_cyan "Connexion au dépot git.cybertron.fr"
if [ ! -f /home/debian/.ssh/id_ed25519 ]
then
    echo_magenta "Génération d'une clé développeur ED25519 pour l'utilisateur debian"
    su -c 'ssh-keygen -t ed25519 -C "debian@$DOMAIN"' debian
fi

echo
echo_magenta "Vous trouverez ci-dessous la clé publique de ce serveur à copier sur https://git.cybertron.fr/-/profile/keys :"
echo
echo_yellow "$(cat /home/debian/.ssh/id_ed25519.pub)"
echo

read -p "Après avoir copié la clé, appuyez sur [ENTREE] pour tester la connexion..."
echo
su -c "ssh -T git@git.cybertron.fr" debian
echo

read -p "Appuyez sur [ENTREE] pour continuer..."