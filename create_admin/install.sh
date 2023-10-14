source /etc/optimus/functions.sh

if [ -z $2 ]
then
	ADMIN_DOMAIN=$DOMAIN
else
	ADMIN_DOMAIN=$2
fi

if [ -z $3 ]
then
	echo_green "Merci d'indiquer le préfixe de l'adresse email du premier administrateur à créer. Exemple 'alice.dupont' pour créer 'alice.dupont@$DOMAIN :"
	read ADMIN_EMAIL_PREFIX
	ADMIN_EMAIL="$ADMIN_EMAIL_PREFIX@$DOMAIN"
else
	ADMIN_EMAIL=$3
fi

if [ -z $4 ]
then
	echo_green "Merci d'indiquer le mot de passe du premier administrateur '$ADMIN_EMAIL_PREFIX'. Au moins 12 caractères, 1 chiffre, 1 majuscule et 1 minuscule :"
	read ADMIN_PASSWORD
else
	ADMIN_PASSWORD=$4
fi

output $OUTPUT_MODE
output $OUTPUT_MODE "CREATION DU COMPTE ADMINISTRATEUR" "blue" 200 "create_admin" 0

output $OUTPUT_MODE "Ajout de *.$DOMAIN dans les allowed_origins" "magenta" 200 "create_admin" 25
verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "REPLACE INTO server.allowed_origins SET  id = 1, origin='*.$DOMAIN'"

output $OUTPUT_MODE "Ajout de $DOMAIN dans les domains" "magenta" 200 "create_admin" 50
verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "REPLACE INTO server.domains SET id = 1, status = b'1', domain='$DOMAIN'"

output $OUTPUT_MODE "Création du compte administrateur $ADMIN_EMAIL" "magenta" 200 "create_admin" 75
verbose apt -qq -y install apache2-utils 2> /dev/null
PASSWORD_HASH=$(htpasswd -bnBC 10 "" "$ADMIN_PASSWORD" | tr -d ':\n')
verbose apt -qq -y remove apache2-utils 2> /dev/null
verbose apt -qq -y autoremove 2> /dev/null
verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "REPLACE INTO server.users SET id = 1, status = b'1', admin = b'1', lastname='Administrateur', email='$ADMIN_EMAIL', password='$PASSWORD_HASH'"
verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS user_1 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

verbose docker cp optimus-base:/srv/sql/user /tmp/sql 2> /dev/null
for file in /tmp/sql/*.sql
do
	verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD user_1 < $file
done
verbose rm -r /tmp/sql

output $OUTPUT_MODE "Le compte administrateur a été créé avec succès" "green" 200 "create_admin" 100