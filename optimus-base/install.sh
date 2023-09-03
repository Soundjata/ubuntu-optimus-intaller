#!/bin/bash
cd /
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DU CONTENEUR OPTIMUS-BASE" "blue" 200 "optimus-base" 0

if [ -z $UUID ]
then
	sed -i 's/UUID=/UUID='$(</dev/urandom tr -dc A-Z0-9 | head -c 16)'/g' /root/.optimus
fi

if [ -z $AES_KEY ]
then
	sed -i 's/AES_KEY=/AES_KEY='$(</dev/urandom tr -dc A-Za-z0-9 | head -c 16)'/g' /root/.optimus
fi

if [ -z $API_SHA_KEY ]
then
	API_SHA_KEY=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 16)
	update_conf API_SHA_KEY $API_SHA_KEY
fi

if [ -z $MARIADB_ROOT_PASSWORD ]
then 
	output $OUTPUT_MODE "Installation impossible. Optimus-databases doit être installé préalablement." "red" 400 "optimus-base" 100
	exit
fi

output $OUTPUT_MODE "Création des dossiers requis" "magenta" 200 "optimus-base" 10

if [ ! -d "/srv/services" ]
then 
	verbose mkdir /srv/services
	chown www-data:www-data -R /srv/services
	chmod 775 /srv/services
fi

if [ ! -d "/srv/www" ]
then 
	verbose mkdir /srv/www
	chown www-data:www-data -R /srv/www
fi

if [ ! -d "/srv/optimus" ]
then 
	verbose mkdir /srv/optimus
	chown www-data:www-data -R /srv/optimus
	chmod 775 -R /srv/optimus
fi

if [ ! -d "/srv/files" ]
then 
	verbose mkdir /srv/files
	chown www-data:www-data -R /srv/files
fi

if [ ! -d "/srv/mailboxes" ]
then 
	[ $(getent group mailboxes) ] || verbose groupadd mailboxes --gid 203 2> /dev/null
	[ $(getent passwd mailboxes) ] || verbose useradd -g mailboxes -s /bin/false -d /srv/mailboxes --uid 203 mailboxes 2> /dev/null
	verbose usermod -a -G mailboxes www-data
	verbose mkdir /srv/mailboxes
	chown mailboxes:mailboxes -R /srv/mailboxes
fi



# if [ $DEV == 1 ]
# then
# 	output $OUTPUT_MODE "Installation des repos (pour le mode développeur)" "magenta" 200 "optimus-base" 20
# 	if [ ! -d /srv/optimus/optimus-libs/.git ]
# 	then
# 		verbose rm -Rf /srv/optimus/optimus-libs
# 		verbose mkdir -p /srv/optimus/optimus-libs
# 		verbose git clone --quiet https://git.cybertron.fr/optimus/optimus-libs /srv/optimus/optimus-libs
# 	fi
# 	if [ ! -d /srv/optimus/optimus-base/.git ]
# 	then
# 		verbose rm -Rf /srv/optimus/optimus-base
# 		verbose mkdir -p /srv/optimus/optimus-base
# 		verbose git clone --quiet https://git.cybertron.fr/optimus/optimus-base /srv/optimus/optimus-base
# 	fi
# 	verbose chmod 775 -R /srv/optimus
# 	verbose chown www-data:www-data -R /srv/optimus
# 	output $OUTPUT_MODE "Ajout de l'utilisateur debian au groupe www-data (pour le mode développeur)" "magenta" 200 "optimus-base" 30
# 	verbose usermod -a -G www-data debian
# 	OPTIMUS_BASE_ADDITIONNAL_VOLUMES="--volume /srv/optimus/optimus-base/api:/srv/api --volume /srv/optimus/optimus-libs:/srv/api/libs"
# 	OPTIMUS_DEV_ADDITIONNAL_VOLUMES="--volume /srv/optimus/optimus-devtools/api:/srv/api --volume /srv/optimus/optimus-libs:/srv/api/libs"
# fi

if [ $( docker ps -a | grep optimus-base | wc -l ) -gt 0 ]
then
	output $OUTPUT_MODE "Suppression du conteneur optimus-base existant" "magenta" 200 "optimus-base" 40
	verbose docker stop optimus-base 2> /dev/null
	verbose docker rm optimus-base 2> /dev/null
	verbose docker stop optimus-base-old 2> /dev/null
	verbose docker rm optimus-base-old 2> /dev/null
fi

output $OUTPUT_MODE "Téléchargement de l'image optimus-base" "magenta" 200 "optimus-base" 50
verbose docker pull --quiet git.cybertron.fr:5050/optimus/optimus-base/v5:latest

output $OUTPUT_MODE "Création du conteneur optimus-base" "magenta" 200 "optimus-base" 60
verbose docker create \
--name optimus-base \
--restart always \
--env NAME=optimus-base \
--env DISPLAYNAME="OPTIMUS Base" \
--env DESCRIPTION="Client et API de base" \
--env PUBLISHER="cybertron" \
--env PUBLISHER_WEBSITE="www.cybertron.fr" \
--env PREREQUISITES=["mariadb"] \
--env VERSION_DATE="202303010000" \
--env VERSION_DISPLAY="5.0" \
--env REPOSITORY="git.cybertron.fr/optimus/optimus-base" \
--env KEEP_ROOT_ACCESS=1 \
--env MARIADB_ROOT_USER=root \
--env MARIADB_ROOT_PASSWORD \
--env AES_KEY \
--env API_SHA_KEY \
--env DOMAIN \
--env OVH_APP_KEY \
--env OVH_SECRET_KEY \
--env OVH_CONSUMER_KEY \
--env ADMIN_FIRSTNAME \
--env ADMIN_LASTNAME \
--env ADMIN_EMAIL_PREFIX \
--env ADMIN_PASSWORD \
--env DEV=$DEV \
--network optimus \
--volume /run/mysqld:/run/mysqld \
--volume /var/run/docker.sock:/var/run/docker.sock \
--volume /var/log/optimus:/var/log/optimus \
--volume /srv/vhosts:/srv/vhosts \
--volume /srv/optimus:/srv/optimus \
--volume /srv/services:/srv/services \
$OPTIMUS_BASE_ADDITIONNAL_VOLUMES \
--user www-data \
--stop-signal SIGTERM \
git.cybertron.fr:5050/optimus/optimus-base/v5:latest

output $OUTPUT_MODE "Lancement du conteneur optimus-base" "magenta" 200 "optimus-base" 70
verbose docker start optimus-base

output $OUTPUT_MODE "Installation de la proposition de service optimus-databases" "magenta" 200 "optimus-base" 72
verbose wget --quiet -O /srv/services/optimus-databases.json https://git.cybertron.fr/optimus/optimus-databases/-/raw/v5-dev/manifest.json

output $OUTPUT_MODE "Installation de la proposition de service optimus-cloud" "magenta" 200 "optimus-base" 74
verbose wget --quiet -O /srv/services/optimus-cloud.json https://git.cybertron.fr/optimus/optimus-cloud/-/raw/v5-dev/manifest.json

output $OUTPUT_MODE "Installation de la proposition de service optimus-avocats" "magenta" 200 "optimus-base" 76
verbose wget --quiet -O /srv/services/optimus-avocats.json https://git.cybertron.fr/optimus/optimus-avocats/-/raw/v5-dev/manifest.json

output $OUTPUT_MODE "Installation de la proposition de service optimus-structures" "magenta" 200 "optimus-base" 78
verbose wget --quiet -O /srv/services/optimus-structures.json https://git.cybertron.fr/optimus/optimus-structures/-/raw/v5-dev/manifest.json

verbose chmod 775 -R /srv/services
verbose chown www-data:www-data -R /srv/services


output $OUTPUT_MODE "Le service OPTIMUS-BASE a été installé avec succès !" "green" 200 "optimus-base" 100