#!/bin/bash
cd /srv/optimus

# LISTE LES SERVICES INSTALLES
INSTALLED_SERVICES="hop la geiss"
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
		
		#INSTALLATION DU NOUVEAU CONTENEUR
		IMAGE="git.cybertron.fr:5050/optimus/optimus-devtools/v5:stable"
		source <(sudo cat /etc/optimus/optimus-init/container_installer.sh)
		read -p "Appuyez sur [ENTREE] pour continuer..."
	else
		echo 
		echo "Nombre invalide ! La réponse doit être comprise entre 1 et $COUNT_SERVICES"
		echo
		read -p "Appuyez sur [ENTREE] pour continuer..."
	fi

elif [ "CHOICE" != "X" ] && [ "CHOICE" != "x" ]
then
	echo
	echo "Réponse invalide. La réponse doit être un nombre compris entre 1 et $COUNT_SERVICES ou X pour quitter"
	echo
	read -p "Appuyez sur [ENTREE] pour continuer..."
fi