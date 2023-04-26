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
      [ $(getent group mailboxes) ] || verbose groupadd mailboxes --gid 203
      [ $(getent passwd mailboxes) ] || verbose useradd -g mailboxes -s /bin/false -d /srv/mailboxes --uid 203 mailboxes
      verbose usermod -a -G mailboxes www-data
      verbose mkdir /srv/mailboxes
      chown mailboxes:mailboxes -R /srv/mailboxes
    fi

    

    if [ $DEV == 1 ]
    then
      echo_magenta "Installation des repos (pour le mode développeur)"
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
      verbose chmod 775 -R /srv/optimus
      verbose chown www-data:www-data -R /srv/optimus
      echo_magenta "Ajout de l'utilisateur debian au groupe www-data (pour le mode développeur)"
      verbose usermod -a -G www-data debian
      OPTIMUS_BASE_ADDITIONNAL_VOLUMES="--volume /srv/optimus/optimus-base/api:/srv/api --volume /srv/optimus/optimus-libs:/srv/api/libs"
      OPTIMUS_DEV_ADDITIONNAL_VOLUMES="--volume /srv/optimus/optimus-devtools/api:/srv/api --volume /srv/optimus/optimus-libs:/srv/api/libs"
    fi

    if [ $( docker ps -a | grep optimus-base | wc -l ) -gt 0 ]
    then
        echo_magenta "Suppression du conteneur optimus-base existant"
        verbose docker stop optimus-base
        verbose docker rm optimus-base
        verbose docker stop optimus-base-old
        verbose docker rm optimus-base-old
    fi

    echo_magenta "Téléchargement de l'image optimus-base"
    verbose docker pull --quiet git.cybertron.fr:5050/optimus/optimus-base/v5:latest

    echo_magenta "Création du conteneur optimus-base"
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
    
    echo_magenta "Lancement du conteneur optimus-base"
    verbose docker start optimus-base

    echo_magenta "Installation de la proposition de service optimus-databases"
    verbose wget --quiet -O /srv/services/optimus-databases.json https://git.cybertron.fr/optimus/optimus-databases/-/raw/v5-dev/manifest.json

    echo_magenta "Installation de la proposition de service optimus-cloud"
    verbose wget --quiet -O /srv/services/optimus-cloud.json https://git.cybertron.fr/optimus/optimus-cloud/-/raw/v5-dev/manifest.json

    echo_magenta "Installation de la proposition de service optimus-avocats"
    verbose wget --quiet -O /srv/services/optimus-avocats.json https://git.cybertron.fr/optimus/optimus-avocats/-/raw/v5-dev/manifest.json

    echo_magenta "Installation de la proposition de service optimus-structures"
    verbose wget --quiet -O /srv/services/optimus-structures.json https://git.cybertron.fr/optimus/optimus-structures/-/raw/v5-dev/manifest.json

    verbose chmod 775 -R /srv/services
    verbose chown www-data:www-data -R /srv/services
    
    if [ $DEV == 1 ]
    then
      echo
      echo_green "==== INSTALLATION DU CONTENEUR OPTIMUS DEV TOOLS ===="

      if [ $( docker ps -a | grep optimus-devtools | wc -l ) -gt 0 ]
      then
          echo_magenta "Suppression du conteneur optimus-devtools existant"
          verbose docker stop optimus-devtools
          verbose docker rm optimus-devtools
          echo_magenta "Suppression de l'image optimus-devtools existante"
          verbose docker image rm git.cybertron.fr:5050/optimus/optimus-devtools/v5:latest
      fi
    
      echo_magenta "Téléchargement de l'image optimus-devtools"
      verbose docker pull --quiet git.cybertron.fr:5050/optimus/optimus-devtools/v5:latest
      
      echo_magenta "Installation du conteneur optimus-devtools"
      verbose docker create \
      --name optimus-devtools \
      --restart always \
      --env NAME=optimus-devtools \
      --env DISPLAYNAME="Optimus Dev Tools" \
      --env DESCRIPTION="Outils de développement" \
      --env PUBLISHER="cybertron" \
      --env PUBLISHER_WEBSITE="www.cybertron.fr" \
      --env PREREQUISITES=["mariadb"] \
      --env VERSION_DATE="202303010000" \
      --env VERSION_DISPLAY="5.0" \
      --env REPOSITORY="git.cybertron.fr/optimus/optimus-devtools" \
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
      $OPTIMUS_DEV_ADDITIONNAL_VOLUMES \
      --network optimus \
      --user www-data \
      --stop-signal SIGTERM \
      git.cybertron.fr:5050/optimus/optimus-devtools/v5:latest
      
      echo_magenta "Lancement du conteneur optimus-devtools"
      verbose docker start optimus-devtools
      
      echo_magenta "Activation de la connexion à distance sur le port 3306 pour l'utilisateur MARIADB root"
      if [ $(which /sbin/ufw) ]
      then 
        verbose /sbin/ufw allow 3306
      fi
    fi

fi