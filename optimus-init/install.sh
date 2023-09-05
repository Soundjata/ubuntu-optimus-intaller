#!/bin/bash
cd /
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "PREPARATION DU SERVEUR POUR LES SERVICES OPTIMUS" "blue" 200 "optimus-init" 0

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
	output $OUTPUT_MODE "Installation impossible. Optimus-databases doit être installé préalablement." "red" 400 "optimus-init" 100
	exit
fi

output $OUTPUT_MODE "Création des dossiers requis" "magenta" 200 "optimus-init" 10

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

output $OUTPUT_MODE "Installation de la proposition de service optimus-databases" "magenta" 200 "optimus-init" 30
verbose wget --quiet -O /srv/services/optimus-databases.json https://git.cybertron.fr/optimus/optimus-databases/-/raw/v5-main/manifest.json

output $OUTPUT_MODE "Installation de la proposition de service optimus-base" "magenta" 200 "optimus-init" 20
verbose wget --quiet -O /srv/services/optimus-base.json https://git.cybertron.fr/optimus/optimus-databases/-/raw/v5-main/manifest.json

output $OUTPUT_MODE "Installation de la proposition de service optimus-cloud" "magenta" 200 "optimus-init" 40
verbose wget --quiet -O /srv/services/optimus-cloud.json https://git.cybertron.fr/optimus/optimus-cloud/-/raw/v5-main/manifest.json

output $OUTPUT_MODE "Installation de la proposition de service optimus-avocats" "magenta" 200 "optimus-init" 50
verbose wget --quiet -O /srv/services/optimus-avocats.json https://git.cybertron.fr/optimus/optimus-avocats/-/raw/v5-main/manifest.json

output $OUTPUT_MODE "Installation de la proposition de service optimus-structures" "magenta" 200 "optimus-init" 60
verbose wget --quiet -O /srv/services/optimus-structures.json https://git.cybertron.fr/optimus/optimus-structures/-/raw/v5-main/manifest.json

verbose chmod 775 -R /srv/services
verbose chown www-data:www-data -R /srv/services

output $OUTPUT_MODE "Le serveur est prêt pour accueillir les services Optimus !" "green" 200 "optimus-init" 100