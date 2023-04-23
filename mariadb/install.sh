#!/bin/bash
cd /
source /etc/optimus-installer/functions.sh
if [ -z $MODULE_MARIADB ]; then require MODULE_MARIADB yesno "Voulez-vous installer le serveur de bases de données MARIADB"; source /root/.optimus-installer; fi
#if [ -z $MODULE_MARIADB_REMOTE_ACCESS ]; then require MODULE_MARIADB_REMOTE_ACCESS yesno "Voulez-vous autoriser la connexion à distance à la base de données ?"; source /root/.optimus-installer; fi
if [ -z $MARIADB_ROOT_PASSWORD ] || [ $MARIADB_ROOT_PASSWORD = "auto" ]; then require MARIADB_ROOT_PASSWORD password "Veuillez renseigner le mot de passe de connexion à distance de l'utilisateur 'root' :"; source /root/.optimus-installer; fi
# if [ -z $AES_KEY ] || [ $AES_KEY = "auto" ]; then require AES_KEY aeskey "Veuillez renseigner une clé de chiffrement AES de 16 caractères [A-Za-z0-9]"; source /root/.optimus-installer; fi
source /root/.optimus-installer

if [ $MODULE_MARIADB = "Y" ]
then
    echo
    echo_green "==== INSTALLATION DU CONTENEUR OPTIMUS DATABASES (MARIADB) ===="

    echo_magenta "Création du groupe mysql (gid 221)"
    verbose groupadd --gid 221 mysql

    echo_magenta "Création de l'utilisateur mysql (uid 221)"
    verbose useradd --no-create-home --home /nonexistent --shell /bin/false --gid 221 --uid 221 mysql 

        echo_magenta "Création des dossiers"
    if [ ! -d "/srv/databases" ]
    then 
        verbose mkdir /srv/databases
        verbose chown mysql:mysql /srv/databases
    fi

    #echo_magenta "Installation du client MARIADB"
    #verbose apt-get -qq -y install mariadb-client

    if [ $( docker container inspect -f '{{.State.Running}}' optimus-databases-v5  2> /dev/null | grep true ) ]
    then
        echo_magenta "Suppression du conteneur existant"
        verbose docker stop optimus-databases-v5
        verbose docker rm optimus-databases-v5
        verbose docker image rm git.cybertron.fr:5050/optimus/optimus-databases/v5:latest
    fi

    echo_magenta "Téléchargement de l'image"
    verbose docker pull --quiet git.cybertron.fr:5050/optimus/optimus-databases/v5:latest

    echo_magenta "Création du conteneur"
    verbose docker create \
    --name optimus-databases-v5 \
    --restart on-failure \
    --env TZ=Europe/Paris \
    --env MARIADB_ROOT_PASSWORD \
    --volume /srv/databases:/var/lib/mysql:rw \
    --volume /run/mysqld:/run/mysqld \
    --network host \
    --cap-add SYS_NICE \
    git.cybertron.fr:5050/optimus/optimus-databases/v5:latest --default-authentication-plugin=mysql_native_password
    
    echo_magenta "Lancement du conteneur"
    verbose docker start optimus-databases-v5
    
    echo_magenta "Attente de l'ouverture du socket MARIADB"
    WAITER=0
    while [[ ! -S /run/mysqld/mysqld.sock && $WAITER -lt 20 ]]
    do
        sleep 1
        let "WAITER+=1"
    done

    # echo_magenta "Fin de l'initialisation du conteneur"
    # sleep $WAITER2

    # if [[ $MODULE_MARIADB_REMOTE_ACCESS =~ ^[YyOo]$ ]]
    # then
    #   echo_magenta "Activation de la connexion à distance sur le port 3306 pour l'utilisateur root"
    #   if [ $(which /sbin/ufw) ]; then verbose /sbin/ufw allow 3306; fi
    #   verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "GRANT ALL ON *.* to 'root'@'%' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION;"
    # else
    #   echo_magenta "Désactivation de la connexion à distance sur le port 3306 pour l'utilisateur root"
    #   if [ $(which /sbin/ufw) ]; then verbose /sbin/ufw deny 3306; fi
    #   verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "DENY ALL ON *.* to 'root'@'%' IDENTIFIED BY '$MARIADB_ROOT_PASSWORD' WITH GRANT OPTION;"
    # fi
fi