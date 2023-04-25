#!/bin/bash
cd /
source /etc/optimus-installer/functions.sh
if [ -z $MODULE_OPTIMUS_BASE ]; then require MODULE_OPTIMUS_BASE yesno "Voulez-vous installer le conteneur OPTIMUS BASE"; source /root/.optimus-installer; fi
if [ -z $MARIADB_ROOT_PASSWORD ] || [ $MARIADB_ROOT_PASSWORD = "auto" ]; then require MARIADB_ROOT_PASSWORD password "Veuillez renseigner le mot de passe de connexion à distance de l'utilisateur 'root' :"; source /root/.optimus-installer; fi
if [ -z $AES_KEY ] || [ $AES_KEY = "auto" ]; then require AES_KEY aeskey "Veuillez renseigner une clé de chiffrement AES de 16 caractères [A-Za-z0-9]"; source /root/.optimus-installer; fi
if [ -z $API_SHA_KEY ] || [ $API_SHA_KEY = "auto" ]; then require API_SHA_KEY aeskey "Veuillez renseigner une clé de chiffrement SHA de 16 caractères [A-Za-z0-9]"; source /root/.optimus-installer; fi
if [ -z $DOMAIN ]; then require DOMAIN string "Veuillez indiquer votre nom de domaine :"; source /root/.optimus-installer; fi
if [ -z $OVH_APP_KEY ]; then require OVH_APP_KEY string "Merci de renseigner votre clé OVH APPLICATION KEY"; source /root/.optimus-installer; fi
if [ -z $OVH_SECRET_KEY ]; then require OVH_SECRET_KEY string "Merci de renseigner votre clé OVH SECRET KEY"; source /root/.optimus-installer; fi
if [ -z $OVH_CONSUMER_KEY ]; then require OVH_CONSUMER_KEY string "Merci de renseigner votre clé OVH CONSUMER KEY"; source /root/.optimus-installer; fi
source /root/.optimus-installer

if [ $MODULE_OPTIMUS_BASE = "Y" ]
then
    echo
    echo_green "==== INSTALLATION DU CONTENEUR OPTIMUS BASE ===="

    echo_magenta "Création des dossiers"
    
    if [ ! -d "/srv/services" ]
    then 
      verbose mkdir /srv/services
      chown www-data:www-data -R /srv/services
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
      chmod +775 -R /srv/optimus
    fi

    if [ ! -d "/srv/files" ]
    then 
      verbose mkdir /srv/files
      chown www-data:www-data -R /srv/files
    fi

       if [ ! -d "/srv/mailboxes" ]
    then 
      [ $(getent group mailboxes) ] || verbose groupadd mailboxes --gid 203
      [ $(getent passwd mailboxes) ] || verbose useradd -g mailboxes -s /bin/false -d /srv/mailboxes --uid 203 mailboxes
      verbose usermod -a -G mailboxes www-data
      verbose mkdir /srv/mailboxes
      chown mailboxes:mailboxes -R /srv/mailboxes
    fi

    if [ $( docker container inspect -f '{{.State.Running}}' optimus-base-v5  2> /dev/null | grep true ) ]
    then
        echo_magenta "Suppression du conteneur existant"
        verbose docker stop optimus-base
        verbose docker rm optimus-base
        verbose docker image rm git.cybertron.fr:5050/optimus/optimus-base/v5:latest
    fi

    echo_magenta "Téléchargement de l'image"
    verbose docker pull --quiet git.cybertron.fr:5050/optimus/optimus-base/v5:latest

    echo_magenta "Création du conteneur"
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
    --volume /run/mysqld:/run/mysqld \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume /var/log/optimus:/var/log/optimus \
    --volume /srv/vhosts:/srv/vhosts \
    --volume /srv/optimus:/srv/optimus \
    --volume /srv/services:/srv/services \
    --network host \
    --user www-data \
    --stop-signal SIGTERM \
    git.cybertron.fr:5050/optimus/optimus-base/v5:latest
    
    echo_magenta "Lancement du conteneur"
    verbose docker start optimus-base
fi