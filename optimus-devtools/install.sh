#!/bin/bash
cd /
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DES OUTILS DE DEVELOPPEMENT" "blue" 200 "optimus-devtools" 0


output $OUTPUT_MODE "Activation de la connexion à distance sur le port 3306 pour l'utilisateur root" "magenta" 200 "optimus-devtools" 10
if [ $(which /sbin/ufw) ]
then 
	verbose /sbin/ufw allow 3306
fi
verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "GRANT ALL ON *.* to 'root'@'%' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION;"


output $OUTPUT_MODE "Installation des dépôts complémentaires" "magenta" 200 "optimus-devtools" 20
if [ ! -d /srv/optimus/optimus-libs/.git ]
then
	verbose rm -Rf /srv/optimus/optimus-libs
	verbose mkdir -p /srv/optimus/optimus-libs
	verbose git clone --quiet https://git.cybertron.fr/optimus/optimus-libs /srv/optimus/optimus-libs
fi

if [ ! -d /srv/optimus/optimus-base/.git ]
then
	verbose rm -Rf /srv/optimus/optimus-base
	verbose mkdir -p /srv/optimus/optimus-base
	verbose git clone --quiet https://git.cybertron.fr/optimus/optimus-base /srv/optimus/optimus-base
fi

if [ ! -d /srv/optimus/optimus-devtools/.git ]
then
	verbose rm -Rf /srv/optimus/optimus-devtools
	verbose mkdir -p /srv/optimus/optimus-devtools
	verbose git clone --quiet https://git.cybertron.fr/optimus/optimus-devtools /srv/optimus/optimus-devtools
fi

output $OUTPUT_MODE "Installation de la proposition de service optimus-devtools" "magenta" 200 "optimus-devtools" 25
verbose wget --quiet -O /srv/services/optimus-structures.json https://git.cybertron.fr/optimus/optimus-devtools/-/raw/v5-dev/manifest.json

output $OUTPUT_MODE "Ajout de l'utilisateur debian au groupe www-data" "magenta" 200 "optimus-devtools" 30
verbose usermod -a -G www-data debian

output $OUTPUT_MODE "Ajout de l'outil de compilation des images" "magenta" 200 "optimus-devtools" 35
verbose cp /etc/optimus/optimus-devtools/build.sh /srv/optimus/build.sh

#OPTIMUS-BASE
output $OUTPUT_MODE "Installation du conteneur optimus-base" "magenta" 200 "optimus-devtools" 40
if [ $( docker ps -a | grep optimus-base | wc -l ) -gt 0 ]
then
	output $OUTPUT_MODE "Suppression du conteneur optimus-base existant" "magenta" 200 "optimus-devtools" 45
	verbose docker stop optimus-base 2> /dev/null
	verbose docker rm optimus-base 2> /dev/null
	verbose docker stop optimus-base-old 2> /dev/null
	verbose docker rm optimus-base-old 2> /dev/null
fi

output $OUTPUT_MODE "Téléchargement de l'image optimus-base" "magenta" 200 "optimus-devtools" 50
verbose docker pull --quiet git.cybertron.fr:5050/optimus/optimus-base/v5:latest

output $OUTPUT_MODE "Création du conteneur optimus-base (développement)" "magenta" 200 "optimus-devtools" 55
verbose docker create \
--name optimus-base \
--restart always \
--env KEEP_ROOT_ACCESS=1 \
--env MARIADB_ROOT_USER=root \
--env MARIADB_ROOT_PASSWORD \
--env AES_KEY \
--env API_SHA_KEY \
--env DOMAIN \
--env OVH_APP_KEY \
--env OVH_SECRET_KEY \
--env OVH_CONSUMER_KEY \
--env DEV=1 \
--network optimus \
--volume /run/mysqld:/run/mysqld \
--volume /var/run/docker.sock:/var/run/docker.sock \
--volume /var/log/optimus:/var/log/optimus \
--volume /srv/vhosts:/srv/vhosts \
--volume /srv/services:/srv/services \
--volume /srv/optimus:/srv/optimus \
--volume /srv/optimus/optimus-base/api:/srv/api \
--volume /srv/optimus/optimus-libs/init.php:/srv/init/init.php \
--volume /srv/optimus/optimus-libs/functions.php:/srv/api/libs/functions.php \
--volume /srv/optimus/optimus-libs/datatables.php:/srv/api/libs/datatables.php \
--volume /srv/optimus/optimus-libs/JWT.php:/srv/api/libs/JWT.php \
--volume /srv/optimus/optimus-libs/docker_socket.php:/srv/api/libs/docker_socket.php \
--user www-data \
--stop-signal SIGTERM \
git.cybertron.fr:5050/optimus/optimus-base/v5:latest

output $OUTPUT_MODE "Lancement du conteneur optimus-base (développement)" "magenta" 200 "optimus-devtools" 60
verbose docker start optimus-base


#OPTIMUS-DEVTOOLS
output $OUTPUT_MODE "Installation du conteneur optimus-devtools" "magenta" 200 "optimus-devtools" 70
if [ $( docker ps -a | grep optimus-devtools | wc -l ) -gt 0 ]
then
	output $OUTPUT_MODE "Suppression du conteneur optimus-devtools existant" "magenta" 200 "optimus-devtools" 75
	verbose docker stop optimus-devtools
	verbose docker rm optimus-devtools
	echo_magenta "Suppression de l'image optimus-devtools existante"
	verbose docker image rm git.cybertron.fr:5050/optimus/optimus-devtools/v5:latest
fi

output $OUTPUT_MODE "Téléchargement de l'image optimus-devtools" "magenta" 200 "optimus-devtools" 80
verbose docker pull --quiet git.cybertron.fr:5050/optimus/optimus-devtools/v5:latest

output $OUTPUT_MODE "Création du conteneur optimus-devtools (développement)" "magenta" 200 "optimus-devtools" 85
verbose docker create \
--name optimus-devtools \
--restart always \
--env KEEP_ROOT_ACCESS=1 \
--env MARIADB_ROOT_USER=root \
--env MARIADB_ROOT_PASSWORD \
--env AES_KEY \
--env API_SHA_KEY \
--env DOMAIN \
--env OVH_APP_KEY \
--env OVH_SECRET_KEY \
--env OVH_CONSUMER_KEY \
--env DEV=1 \
--volume /run/mysqld:/run/mysqld \
--volume /var/run/docker.sock:/var/run/docker.sock \
--volume /var/log/optimus:/var/log/optimus \
--volume /srv/vhosts:/srv/vhosts \
--volume /srv/services:/srv/services \
--volume /srv/optimus/optimus-devtools/api:/srv/api \
--volume /srv/optimus/optimus-libs/init.php:/srv/init/init.php \
--volume /srv/optimus/optimus-libs/functions.php:/srv/api/libs/functions.php \
--volume /srv/optimus/optimus-libs/datatables.php:/srv/api/libs/datatables.php \
--volume /srv/optimus/optimus-libs/JWT.php:/srv/api/libs/JWT.php \
--volume /srv/optimus/optimus-libs/docker_socket.php:/srv/api/libs/docker_socket.php \
--network optimus \
--user www-data \
--stop-signal SIGTERM \
git.cybertron.fr:5050/optimus/optimus-devtools/v5:latest

output $OUTPUT_MODE "Lancement du conteneur optimus-devtools (développement)" "magenta" 200 "optimus-devtools" 90
verbose docker start optimus-devtools

output $OUTPUT_MODE "Attribution des droits en écriture sur les dépôts" "magenta" 200 "optimus-devtools" 95
verbose chmod 775 -R /srv/optimus
verbose chown www-data:www-data -R /srv/optimus

output $OUTPUT_MODE "Les outils de développement ont été installés avec succès" "green" 200 "optimus-devtools" 100
