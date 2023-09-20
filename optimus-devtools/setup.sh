#!/bin/bash
cd /srv/optimus

# LISTE LES IMAGES DISPONIBLES SUR LE GIT CYBERTRON
OPTIMUS_REPO=$(curl -s https://git.cybertron.fr/api/v4/groups/optimus/projects?search=optimus-&simple=true)
AVAILABLE_IMAGES=()

PROJECTS=$(echo $OPTIMUS_REPO | jq -c '.[] | {name: .name, path: .web_url, branch: .default_branch}')
for PROJECT in $PROJECTS
do
	PROJECT_NAME=$(echo $PROJECT | jq -r .name)
	if [ $PROJECT_NAME != "optimus-libs" ] && [ $PROJECT_NAME != "optimus-container" ] && [ $PROJECT_NAME != "optimus-installer" ]
	then
		AVAILABLE_IMAGES+=("git.cybertron.fr:5050/optimus/$PROJECT_NAME/v5:stable")
	fi
done

COUNT_IMAGES=${#AVAILABLE_IMAGES[@]}

# AFFICHAGE DU MENU INTERACTIF
echo
echo "Selectionnez le conteneur que vous souhaitez installer ?"
echo
for ((i=1; i <= $COUNT_IMAGES; i++))
do
	echo -e "  \e[32m$i. ${AVAILABLE_IMAGES[$i-1]}\e[0m"
done

echo
echo -e "  \e[31mX. Quitter\e[0m"
echo
read -p "Sélectionnez une option (1-$COUNT_IMAGES ou X): " CHOICE

#TRAITEMENT DU CHOIX DE L'UTILISATEUR
if [[ $CHOICE =~ ^[0-9]+$ ]]
then

	if [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le $COUNT_IMAGES ]
	then

		SELECTED_SERVICE="${AVAILABLE_IMAGES[$((CHOICE-1))]}"
		
		#INSTALLATION DU NOUVEAU CONTENEUR
		IMAGE=$SELECTED_SERVICE
		source <(sudo cat /etc/optimus/optimus-init/container_installer.sh)
		read -p "Appuyez sur [ENTREE] pour continuer..."
	else
		echo 
		echo "Nombre invalide ! La réponse doit être comprise entre 1 et $COUNT_IMAGES"
		echo
		read -p "Appuyez sur [ENTREE] pour continuer..."
	fi

elif [ "$CHOICE" != "X" ] && [ "$CHOICE" != "x" ]
then
	echo
	echo "Réponse invalide. La réponse doit être un nombre compris entre 1 et $COUNT_IMAGES ou X pour quitter"
	echo
	read -p "Appuyez sur [ENTREE] pour continuer..."
fi