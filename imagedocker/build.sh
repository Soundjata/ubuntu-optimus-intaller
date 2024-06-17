#!/bin/bash
cd /
source /etc/optimus/functions.sh

docker login  -u soundjata01 -p dckr_pat_V_YWCxgbhgpven5vEhKn5zKZbo4

output $OUTPUT_MODE
output $OUTPUT_MODE "Installation des librairies OPTIMUS" "magenta" 200 "optimus-build-imagedockers" 10

# LISTE LES IMAGES DISPONIBLES SUR LE GIT CYBERTRON
OPTIMUS_REPO=$(curl -s https://git.cybertron.fr/api/v4/projects?topic=service&simple=true)
AVAILABLE_PROJECT=()

PROJECTS=$(echo $OPTIMUS_REPO | jq -c '.[] | {id: .id, name: .name, path: .web_url, branch: .default_branch}')
for PROJECT in $PROJECTS
do
	PROJECT_NAME=$(echo $PROJECT | jq -r .name)
	PROJECT_ID=$(echo $PROJECT | jq -r .id)
	AVAILABLE_PROJECT+=("$PROJECT_NAME")
	AVAILABLE_PROJECT_ID+=("$PROJECT_ID")
done

COUNT_IMAGES=${#AVAILABLE_PROJECT[@]}

# AFFICHAGE DU MENU INTERACTIF
echo
echo "Selectionnez le conteneur que vous souhaitez installer ?"
echo
for ((i=1; i <= $COUNT_IMAGES; i++))
do
	echo -e "  \e[32m$i. ${AVAILABLE_PROJECT[$i-1]}\e[0m"
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

		SELECTED_SERVICE="${AVAILABLE_PROJECT[$((CHOICE-1))]}"
		
		#INSTALLATION DU NOUVEAU CONTENEUR
		IMAGE=$SELECTED_SERVICE
		#source <(sudo cat /etc/optimus/optimus-init/container_installer.sh)
		#echo $IMAGE
		OPTIMUS_BRANCHE=$(curl -s https://git.cybertron.fr/api/v4/projects/$AVAILABLE_PROJECT_ID/repository/branches)
		BRANCHES=$(echo $OPTIMUS_BRANCHE | jq -c '.[] | {branch: .name}')
		for BRANCHE in $BRANCHES
		do
			PROJECT_BRANCHE=$(echo $BRANCHE | jq -r .branch)
			AVAILABLE_PROJECT_BRANCHE+=("$PROJECT_BRANCHE")
			#echo $PROJECT_BRANCHE
			if [ ! -d "/etc/optimus/imagedocker/$PROJECT_BRANCHE" ]
			then
				echo $PROJECT_BRANCHE
				mkdir -p "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE"
				chown ubuntu:ubuntu "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE"
				git clone --branch $PROJECT_BRANCHE https://git.cybertron.fr/optimus/$IMAGE /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE

				mv /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE/Dockerfile /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE 

				mkdir -p "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs"
				chown ubuntu:ubuntu "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs"
				git /etc/optimus/imagedocker/optimus-libs /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs

				cd /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE
				docker buildx create --use --platform=linux/arm64,linux/amd64 --name $IMAGE-$PROJECT_BRANCHE
				docker buildx inspect --bootstrap
				docker buildx build --platform linux/amd64,linux/arm64 --push -t soundjata01/$IMAGE:$PROJECT_BRANCHE .
				docker buildx rm -f $IMAGE-$PROJECT_BRANCHE

			else
				if [ ! -d "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE" ]
				then
					#echo $IMAGE
					mkdir -p "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE"
					chown ubuntu:ubuntu "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE"
					git clone --branch $PROJECT_BRANCHE https://git.cybertron.fr/optimus/$IMAGE /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE

					mv /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE/Dockerfile /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE

					mkdir -p "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs"
					chown ubuntu:ubuntu "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs"
					git clone https://git.cybertron.fr/optimus/optimus-libs /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs

					cd /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE
					docker buildx create --use --platform=linux/arm64,linux/amd64 --name $IMAGE-$PROJECT_BRANCHE
					docker buildx inspect --bootstrap
					docker buildx build --platform linux/amd64,linux/arm64 --push -t soundjata01/$IMAGE:$PROJECT_BRANCHE .
					docker buildx rm -f $IMAGE-$PROJECT_BRANCHE
				else
					rm -Rf "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE"
					mkdir -p "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE"
					chown ubuntu:ubuntu "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE"
					git clone --branch $PROJECT_BRANCHE https://git.cybertron.fr/optimus/$IMAGE /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE

					mv /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/$IMAGE/Dockerfile /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE

					rm -Rf "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs"
					mkdir -p "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs"
					chown ubuntu:ubuntu "/etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs"
					git clone https://git.cybertron.fr/optimus/optimus-libs /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE/optimus-libs

					cd /etc/optimus/imagedocker/$PROJECT_BRANCHE/$IMAGE-$PROJECT_BRANCHE
					docker buildx create --use --platform=linux/arm64,linux/amd64 --name $IMAGE-$PROJECT_BRANCHE
					docker buildx inspect --bootstrap
					docker buildx build --platform linux/amd64,linux/arm64 --push -t soundjata01/$IMAGE:$PROJECT_BRANCHE .
					docker buildx rm -f $IMAGE-$PROJECT_BRANCHE
				fi
			fi
		done

		
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