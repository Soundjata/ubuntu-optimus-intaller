#!/bin/bash
cd /
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "PREPARATION DU SERVEUR POUR LES OUTILS DE DEVELOPPEMENT" "blue" 200 "optimus-devtools" 0


output $OUTPUT_MODE "Activation de la connexion à distance sur le port 3306 pour l'utilisateur root" "magenta" 200 "optimus-devtools" 15
if [ $(which /sbin/ufw) ]
then 
	verbose /sbin/ufw allow 3306
fi
verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "GRANT ALL ON *.* to 'root'@'%' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION;"

output $OUTPUT_MODE "Création d'un swap de 1Go" "magenta" 200 "optimus-devtools" 30
if [[ $(sudo /usr/sbin/swapon -s) != *"/var/swap.img"* ]]
then
	sudo dd if=/dev/zero of=/var/swap.img bs=1024 count=1024k
	sudo chmod 600 /var/swap.img
	sudo mkswap /var/swap.img
	sudo swapon /var/swap.img
	sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
fi

output $OUTPUT_MODE "Ajout de l'utilisateur debian au groupe www-data" "magenta" 200 "optimus-devtools" 45
verbose usermod -a -G www-data debian


output $OUTPUT_MODE "Attribution des droits en écriture sur les dépôts" "magenta" 200 "optimus-devtools" 60
verbose chmod 775 -R /srv/optimus
verbose chown www-data:www-data -R /srv/optimus

echo
echo
echo_cyan "Connexion au registre de conteneurs https://git.cybertron.fr:5050"

echo
echo_green "Veuillez indiquer votre identifiant git.cybertron.fr :"
read GIT_USERNAME

echo
echo_green "Veuillez indiquer votre mot de passe git.cybertron.fr :"
read GIT_PASSWORD

docker logout
echo
su -c "docker login https://git.cybertron.fr:5050 -u '$GIT_USERNAME' -p '$GIT_PASSWORD'" debian

echo
echo
echo_cyan "Connexion au dépot git.cybertron.fr"
su -c 'git config --global user.name "'$GIT_USERNAME'"' debian
su -c 'git config --global user.email "'$GIT_USERNAME'"' debian
su -c 'git config --global --add safe.directory "*"' debian
if [ ! -f /home/debian/.ssh/id_ed25519 ]
then
	echo_magenta "Génération d'une clé développeur ED25519 pour l'utilisateur debian"
	su -c 'ssh-keygen -t ed25519 -f "/home/debian/.ssh/id_ed25519" -N "" -C "debian@$DOMAIN"' debian
fi

echo
echo_magenta "Vous trouverez ci-dessous la clé publique de ce serveur à copier sur https://git.cybertron.fr/-/profile/keys :"
echo
echo_yellow "$(cat /home/debian/.ssh/id_ed25519.pub)"
echo

read -p "Après avoir copié la clé, appuyez sur [ENTREE] pour tester la connexion..."
echo
su -c "ssh -T -o 'StrictHostKeyChecking no' git@git.cybertron.fr" debian
echo

read -p "Appuyez sur [ENTREE] pour continuer..."

output $OUTPUT_MODE
output $OUTPUT_MODE "Installation des librairies OPTIMUS" "magenta" 200 "optimus-devtools" 70
if [ ! -d "/srv/optimus/optimus-libs/.git" ]
then
	rm -Rf "/srv/optimus/optimus-libs"
	mkdir -p "/srv/optimus/optimus-libs"
	chown debian:debian "/srv/optimus/optimus-libs"
	su -c "git clone git@git.cybertron.fr:optimus/optimus-libs /srv/optimus/optimus-libs" debian
fi

output $OUTPUT_MODE
output $OUTPUT_MODE "Installation de l'environnement VS CODIUM" "magenta" 200 "optimus-devtools" 80
if [ ! -f "/home/debian/optimus.code-workspace" ]
then
	cp /etc/optimus/optimus-devtools/optimus.code-workspace /home/debian/optimus.code-workspace
fi

output $OUTPUT_MODE
output $OUTPUT_MODE "Réinstallation du repo optimus-installer (DEV MODE)" "magenta" 200 "optimus-devtools" 90
verbose rm -R /etc/optimus
verbose mkdir -p /etc/optimus
chown debian:debian /etc/optimus
su -c 'git clone --quiet git@git.cybertron.fr:optimus/optimus-installer /etc/optimus' debian

output $OUTPUT_MODE "Les outils de développement ont été installés avec succès" "green" 200 "optimus-devtools" 100

IMAGE=git.cybertron.fr:5050/optimus/optimus-devtools/v5:stable
source /etc/optimus/optimus-init/container_installer.sh
