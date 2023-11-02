#!/bin/bash
cd /srv/optimus

# LISTE LES SERVICES INSTALLES
#INSTALLED_SERVICES=$(mariadb -u root -p$MARIADB_ROOT_PASSWORD -N -e "SELECT name FROM server.services")
INSTALLED_SERVICES=()
COUNT_SERVICES=0

for dir in "/srv/optimus"/*/
do
	if [ -f "$dir/Dockerfile" ]
	then
		INSTALLED_SERVICES+=("$(basename "$dir")")
		COUNT_SERVICES=$[COUNT_SERVICES + 1]
	fi
done

#COUNT_SERVICES=$(echo "$INSTALLED_SERVICES" | wc -l)
echo ${INSTALLED_SERVICES[@]}

# AFFICHAGE DU MENU INTERACTIF
echo
echo "Selectionnez le conteneur que vous souhaitez passer en mode développement :"
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
			echo
			echo "Téléchargement du code source"
			rm -Rf "/srv/optimus/$SELECTED_SERVICE"
			mkdir -p "/srv/optimus/$SELECTED_SERVICE"
			chown debian:debian "/srv/optimus/$SELECTED_SERVICE"
			su -c "git clone git@git.cybertron.fr:optimus/$SELECTED_SERVICE /srv/optimus/$SELECTED_SERVICE" debian
		fi
		
		#LE CODE DOIT APPARTENIR A L'UTILISATEUR WWW-DATA
		chown -R www-data:www-data /srv/optimus
		chmod 775 -R /srv/optimus
		
		#MISE A JOUR DE LA DATE DE VERSION DANS LE FICHIER MANIFEST
		echo
		echo "Mise à jour du fichier manifest.json"
		OLDTIME=$(cat /srv/optimus/$SELECTED_SERVICE/manifest.json | jq -r .version_date)
		NEWTIME=$(date -u +'%Y%m%d%H%M%S')
		sed -i 's/"version_date": "'$OLDTIME'"/"version_date": "'$NEWTIME'"/' /srv/optimus/$SELECTED_SERVICE/manifest.json
		
		#CONSTRUCTION DE LA NOUVELLE IMAGE
		echo
		echo "Construction de la nouvelle image :"
		echo
		docker build -t git.cybertron.fr:5050/optimus/$SELECTED_SERVICE/v5:dev -f $SELECTED_SERVICE/Dockerfile .
		
		#INSTALLATION DU NOUVEAU CONTENEUR
		DEV=1
		IMAGE=$(cat /srv/optimus/$SELECTED_SERVICE/manifest.json | jq -r .image)
		IMAGE="$IMAGE/v5"
		NAME=$SELECTED_SERVICE
		source <(sudo cat /etc/optimus/optimus-init/container_installer.sh)
		echo
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