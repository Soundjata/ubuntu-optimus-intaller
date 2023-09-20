#!/bin/bash
cd /srv/optimus

# LISTE LES SERVICES INSTALLES
INSTALLED_SERVICES=$(mariadb -u root -p$MARIADB_ROOT_PASSWORD -N -e "SELECT name FROM server.services")
COUNT_SERVICES=$(echo "$INSTALLED_SERVICES" | wc -l)
INSTALLED_SERVICES=($INSTALLED_SERVICES)

# AFFICHAGE DU MENU INTERACTIF
echo "Selectionnez le conteneur que vous souhaitez passer en mode développement ?"
echo
for ((i=1; i <= $COUNT_SERVICES; i++))
do
	echo -e "  \e[32m$i. ${INSTALLED_SERVICES[$i-1]}\e[0m"
done

echo
echo -e "  \e[31mX. Quitter\e[0m"
echo
read -p "Sélectionnez une option (1-$COUNT_SERVICES ou X): " CHOICE

#TRAITEMENT DU CHOIX DE L'UTILISATEUR
if [[ $CHOICE =~ ^[0-9]+$ ]]
then

	if [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le $COUNT_SERVICES ]
	then

		SELECTED_SERVICE="${INSTALLED_SERVICES[$((CHOICE-1))]}"
		
		#INSTALLATION DU CODE SOURCE DE LA BRANCHE DEV
		if [ ! -d "/srv/optimus/$SELECTED_SERVICE/.git" ]
		then
			rm -Rf "/srv/optimus/$SELECTED_SERVICE"
			mkdir -p "/srv/optimus/$SELECTED_SERVICE"
			chown debian:debian "/srv/optimus/$SELECTED_SERVICE"
			su -c "git clone git@git.cybertron.fr:optimus/$SELECTED_SERVICE /srv/optimus/$SELECTED_SERVICE" debian
		fi
		
		#INSTALLATION DU REPO OPTIMUS LIBS
		if [ ! -d "/srv/optimus/optimus-libs/.git" ]
		then
			rm -Rf "/srv/optimus/optimus-libs"
			mkdir -p "/srv/optimus/optimus-libs"
			chown debian:debian "/srv/optimus/optimus-libs"
			su -c "git clone git@git.cybertron.fr:optimus/optimus-libs /srv/optimus/optimus-libs" debian
		fi
		
		#INSTALLATION DU FICHIER .VSCODE QUI CONTIENT LES PARAMETRES DE SYNTAXE DU CODE
		if [ ! -d "/srv/optimus/.vscode" ]
		then
			mkdir -p "/srv/optimus/.vscode"
			wget -O "/srv/optimus/.vscode/settings.json" "https://git.cybertron.fr/optimus/optimus-libs/-/raw/v5-dev/.vscode/settings.json"
		fi
		
		#LE CODE DOIT APPARTENIR A L'UTILISATEUR DEBIAN
		chown -R www-data:www-data /srv/optimus
		chmod 775 -R /srv/optimus
		
		#MISE A JOUR DE LA DATE DE VERSION DANS LE FICHIER MANIFEST
		OLDTIME=$(cat /srv/optimus/$SELECTED_SERVICE/manifest.json | jq -r .version_date)
		NEWTIME=$(printf '%(%Y%m%d%H%M%S)T')
		sed -i 's/"version_date": "'$OLDTIME'"/"version_date": "'$NEWTIME'"/' /srv/optimus/$SELECTED_SERVICE/manifest.json
		
		#CONSTRUCTION DE LA NOUVELLE IMAGE
		docker build -t git.cybertron.fr:5050/optimus/$SELECTED_SERVICE/v5:dev -f $SELECTED_SERVICE/Dockerfile .
		
		#INSTALLATION DU NOUVEAU CONTENEUR
		DEV=1
		IMAGE=$(cat /srv/optimus/$SELECTED_SERVICE/manifest.json | jq -r .image)
		NAME=$SELECTED_SERVICE
		source <(sudo cat /etc/optimus/optimus-init/container_installer.sh)
		read -p "Appuyez sur [ENTREE] pour continuer..."
	else
		echo 
		echo "Nombre invalide ! La réponse doit être comprise entre 1 et $COUNT_SERVICES"
		echo
		read -p "Appuyez sur [ENTREE] pour continuer..."
	fi

elif [ "$CHOICE" != "X" ] && [ "$CHOICE" != "x" ]
then
	echo
	echo "Réponse invalide. La réponse doit être un nombre compris entre 1 et $COUNT_SERVICES ou X pour quitter"
	echo
	read -p "Appuyez sur [ENTREE] pour continuer..."
fi