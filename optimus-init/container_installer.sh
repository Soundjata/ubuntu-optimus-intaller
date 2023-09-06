#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
if [ "$DEV" == "1" ]
then
    output $OUTPUT_MODE "INSTALLATION DU CONTENEUR ${NAME^^} (DEV MODE)" "blue" 200 "$NAME" 0
    BRANCH="dev"
else
    output $OUTPUT_MODE "INSTALLATION DU CONTENEUR ${NAME^^}" "blue" 200 "$NAME" 0
    BRANCH="main"
fi

output $OUTPUT_MODE "Installation de la proposition de service $NAME" "magenta" 200 "$NAME" 20
verbose wget --quiet -O /srv/services/$NAME.json https://git.cybertron.fr/optimus/$NAME/-/raw/v5-$BRANCH/manifest.json
chown www-data:www-data /srv/services/$NAME.json

output $OUTPUT_MODE "Lecture du fichier manifest.json" "magenta" 200 "$NAME" 30
IMAGE=$(jq -r .image /srv/services/$NAME.json)
ENV=""; for row in $(jq -r .env[] /srv/services/$NAME.json); do ENV+="--env $row "; done
VOLUMES=""; for row in $(jq -r .volumes[] /srv/services/$NAME.json); do VOLUMES+="--volume $row "; done
if [ "$(jq -r .stop_signal /srv/services/$NAME.json)" != "null" ]; then STOP_SIGNAL="--stop-signal $(jq -r .stop_signal /srv/services/$NAME.json) "; fi
if [ "$(jq -r .user /srv/services/$NAME.json)" != "null" ]; then USER="--user $(jq -r .user /srv/services/$NAME.json) "; fi
if [ "$(jq -r .restart_policy.name /srv/services/$NAME.json)" != "null" ]; then RESTART="--restart $(jq -r .restart_policy.name /srv/services/$NAME.json) "; fi

if [ "$DEV" == "1" ]
then
    IMAGE="${IMAGE//latest/dev}"
    DEV_ENV=""; for row in $(jq -r .dev.env[] /srv/services/$NAME.json); do DEV_ENV+="--env $row "; done
    DEV_VOLUMES=""; for row in $(jq -r .dev.volumes[] /srv/services/$NAME.json); do DEV_VOLUMES+="--volume $row "; done
fi

if [ $( docker ps -a | grep $NAME | wc -l ) -gt 0 ]
then
	output $OUTPUT_MODE "Suppression du conteneur $NAME existant" "magenta" 200 "$NAME" 40
	verbose docker stop $NAME 2> /dev/null
	verbose docker rm --force $NAME 2> /dev/null
	verbose docker stop $NAME-old 2> /dev/null
	verbose docker rm --force $NAME-old 2> /dev/null
fi

if [ "$DEV" != "1" ]
then
	output $OUTPUT_MODE "Téléchargement de l'image $NAME" "magenta" 200 "$NAME" 50
	verbose docker pull --quiet $IMAGE
fi

output $OUTPUT_MODE "Création du conteneur $NAME" "magenta" 200 "$NAME" 70
verbose docker create --name $NAME --network optimus $ENV $DEV_ENV $RESTART $USER $STOP_SIGNAL $VOLUMES $DEV_VOLUMES $IMAGE

output $OUTPUT_MODE "Lancement du conteneur $NAME" "magenta" 200 "$NAME" 80
verbose docker start $NAME

if [ "$DEV" == "1" ]
then
    output $OUTPUT_MODE "Le conteneur $NAME (DEV MODE) a été installé avec succès !" "green" 200 "$NAME" 100
    BRANCH="dev"
else
    output $OUTPUT_MODE "Le conteneur $NAME a été installé avec succès !" "green" 200 "$NAME" 100
    BRANCH="main"
fi
