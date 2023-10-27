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

output $OUTPUT_MODE "Création des dossiers requis" "magenta" 200 "optimus-init" 25

if [ ! -d "/srv/www" ]
then 
	verbose mkdir /srv/www
fi
chown www-data:www-data -R /srv/www

if [ ! -d "/srv/optimus" ]
then 
	verbose mkdir /srv/optimus
fi
chown www-data:www-data -R /srv/optimus
chmod 775 -R /srv/optimus

if [ ! -d "/srv/websocket" ]
then 
	verbose mkdir /srv/websocket
fi
chown www-data:www-data -R /srv/websocket
chmod 775 -R /srv/optimus

if [ ! -d "/srv/files" ]
then 
	verbose mkdir /srv/files
fi
chown www-data:www-data -R /srv/files

if [ ! -d "/srv/mailboxes" ]
then 
	[ $(getent group mailboxes) ] || verbose groupadd mailboxes --gid 203 2> /dev/null
	[ $(getent passwd mailboxes) ] || verbose useradd -g mailboxes -s /bin/false -d /srv/mailboxes --uid 203 mailboxes 2> /dev/null
	verbose usermod -a -G mailboxes www-data
	verbose mkdir /srv/mailboxes
	chown www-data:mailboxes -R /srv/mailboxes
	chmod 770 -R /srv/mailboxes
fi

output $OUTPUT_MODE "Le serveur est prêt pour accueillir les services Optimus !" "green" 200 "optimus-init" 100