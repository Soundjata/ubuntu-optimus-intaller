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

output $OUTPUT_MODE "Ajout du domaine $DOMAIN dans les allowed_origins" "magenta" 200 "create_admin" 33
verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "REPLACE INTO server.allowed_origins SET origin='*.$DOMAIN'"

output $OUTPUT_MODE "Création du compte administrateur $ADMIN_EMAIL" "magenta" 200 "create_admin" 66
verbose mariadb -u root -p$MARIADB_ROOT_PASSWORD -e "REPLACE INTO server.users SET status = b'1', admin = b'1', lastname='Administrateur', email='$ADMIN_EMAIL', password=AES_ENCRYPT('$ADMIN_PASSWORD','$AES_KEY')"

output $OUTPUT_MODE "Le compte administrateur a été créé avec succès" "green" 200 "create_admin" 100