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


output $OUTPUT_MODE "Installation des dépôts complémentaires" "magenta" 200 "optimus-devtools" 30
if [ ! -d /srv/optimus/optimus-libs/.git ]
then
	verbose rm -Rf /srv/optimus/optimus-libs
	verbose mkdir -p /srv/optimus/optimus-libs
	verbose git clone --quiet git@git.cybertron.fr/optimus/optimus-libs /srv/optimus/optimus-libs
fi


output $OUTPUT_MODE "Ajout de l'utilisateur debian au groupe www-data" "magenta" 200 "optimus-devtools" 45
verbose usermod -a -G www-data debian


output $OUTPUT_MODE "Attribution des droits en écriture sur les dépôts" "magenta" 200 "optimus-devtools" 60
verbose chmod 775 -R /srv/optimus
verbose chown www-data:www-data -R /srv/optimus


output $OUTPUT_MODE "Ajout de l'outil de compilation des images" "magenta" 200 "optimus-devtools" 75
verbose cp /etc/optimus/optimus-devtools/build.sh /srv/optimus/build.sh

output $OUTPUT_MODE "Le serveur est prêt pour accueillir les outils de développement" "green" 200 "optimus-devtools" 100


DEV=1
NAME="optimus-base"
source /etc/optimus/optimus-init/container_installer.sh

DEV=1
NAME="optimus-devtools"
source /etc/optimus/optimus-init/container_installer.sh