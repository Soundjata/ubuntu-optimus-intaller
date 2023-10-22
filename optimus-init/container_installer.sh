#!/bin/bash
source /etc/optimus/functions.sh

if [ "$DEV" == "1" ]
then
	IMAGE="$IMAGE:dev"
else
	IMAGE="$IMAGE:stable"
fi
IMAGE_ID=$(docker create $IMAGE)
verbose docker cp $IMAGE_ID:/srv/manifest.json /tmp/$IMAGE_ID.json 2> /dev/null
verbose docker rm --force $IMAGE_ID 2> /dev/null 2> /dev/null
NAME=$(jq -r .name /tmp/$IMAGE_ID.json)

output $OUTPUT_MODE
if [ "$DEV" == "1" ]
then
	output $OUTPUT_MODE "INSTALLATION DU CONTENEUR ${NAME^^} (DEV MODE)" "blue" 200 "$NAME" 0
else
	output $OUTPUT_MODE "INSTALLATION DU CONTENEUR ${NAME^^}" "blue" 200 "$NAME" 0
fi


ENV=""; for row in $(jq -r .env[] /tmp/$IMAGE_ID.json); do ENV+="--env $row "; done
VOLUMES=""; for row in $(jq -r .volumes[] /tmp/$IMAGE_ID.json); do VOLUMES+="--volume $row "; done
if [ "$(jq -r .stop_signal /tmp/$IMAGE_ID.json)" != "null" ]; then STOP_SIGNAL="--stop-signal $(jq -r .stop_signal /tmp/$IMAGE_ID.json) "; fi
if [ "$(jq -r .user /tmp/$IMAGE_ID.json)" != "null" ]; then USER="--user $(jq -r .user /tmp/$IMAGE_ID.json) "; fi
if [ "$(jq -r .restart_policy.name /tmp/$IMAGE_ID.json)" != "null" ]; then RESTART="--restart $(jq -r .restart_policy.name /tmp/$IMAGE_ID.json) "; fi

if [ "$DEV" == "1" ]
then
	DEV_ENV=""; for row in $(jq -r .dev.env[] /tmp/$IMAGE_ID.json); do DEV_ENV+="--env $row "; done
	DEV_VOLUMES=""; for row in $(jq -r .dev.volumes[] /tmp/$IMAGE_ID.json); do DEV_VOLUMES+="--volume $row "; done
fi

if [ $( docker ps -a | grep $NAME | wc -l ) -gt 0 ]
then
	output $OUTPUT_MODE "Suppression du conteneur $NAME existant" "magenta" 200 "$NAME" 40
	verbose docker stop $NAME 2> /dev/null
	verbose docker rm --force $NAME 2> /dev/null
	verbose docker stop $NAME-old 2> /dev/null
	verbose docker rm --force $NAME-old 2> /dev/null
fi

output $OUTPUT_MODE "Création du conteneur $NAME" "magenta" 200 "$NAME" 70
verbose eval "docker create --name $NAME --network optimus --log-driver json-file --log-opt max-size=100m $ENV $DEV_ENV $RESTART $USER $STOP_SIGNAL $VOLUMES $DEV_VOLUMES $IMAGE"

output $OUTPUT_MODE "Lancement du conteneur $NAME" "magenta" 200 "$NAME" 80
verbose docker start $NAME

verbose rm /tmp/$IMAGE_ID.json

if [ "$DEV" == "1" ]
then
	output $OUTPUT_MODE "Le conteneur $NAME (DEV MODE) a été installé avec succès !" "green" 200 "$NAME" 100
else
	output $OUTPUT_MODE "Le conteneur $NAME a été installé avec succès !" "green" 200 "$NAME" 100
fi
