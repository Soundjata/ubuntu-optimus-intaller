#!/bin/bash
cd /
source /etc/optimus/functions.sh

if [ -z $MARIADB_ROOT_PASSWORD ]
then 
	MARIADB_ROOT_PASSWORD=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 16)
	update_conf MARIADB_ROOT_PASSWORD $MARIADB_ROOT_PASSWORD
fi

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DU CONTENEUR OPTIMUS-DATABASES (MARIADB)" "blue" 200 "optimus-databases" 0

output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "optimus-databases" 10
verbose apt -qq --yes install mariadb-client 2> /dev/null

output $OUTPUT_MODE "Création du groupe mysql (gid 221)" "magenta" 200 "optimus-databases" 20
verbose groupadd --gid 221 mysql 2> /dev/null

output $OUTPUT_MODE "Création de l'utilisateur mysql (uid 221)" "magenta" 200 "optimus-databases" 30
verbose useradd --no-create-home --home /nonexistent --shell /bin/false --gid 221 --uid 221 mysql 2> /dev/null

if [ ! -d "/srv/databases" ]
then
	output $OUTPUT_MODE "Création du dossier /srv/databases" "magenta" 200 "optimus-databases" 40
	verbose mkdir /srv/databases
	verbose chown mysql:mysql /srv/databases
fi

if [ $( docker ps -a | grep optimus-databases | wc -l ) -gt 0 ]
then
	output $OUTPUT_MODE "Suppression du conteneur existant" "magenta" 200 "optimus-databases" 50
	verbose docker stop optimus-databases
	verbose docker rm optimus-databases
fi

IMAGE="git.cybertron.fr:5050/optimus/optimus-databases/v5"
source /etc/optimus/optimus-init/container_installer.sh

output $OUTPUT_MODE "Attente de l'ouverture du socket MARIADB" "magenta" 200 "optimus-databases" 90
WAITER=0
while [[ ! -S /run/mysqld/mysqld.sock && $WAITER -lt 20 ]]
do
	sleep 1
	let "WAITER+=1"
done

output $OUTPUT_MODE "Connexion à la base de donnée établie !" "green" 200 "optimus-databases" 100