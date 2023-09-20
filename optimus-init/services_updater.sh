#!/bin/bash

OPTIMUS_REPO=$(curl -s https://git.cybertron.fr/api/v4/groups/optimus/projects?search=optimus-&simple=true)

PROJECTS=$(echo $OPTIMUS_REPO | jq -c '.[] | {name: .name, path: .web_url, branch: .default_branch}')
for PROJECT in $PROJECTS
do
	PROJECT_NAME=$(echo $PROJECT | jq -r .name)
	PROJECT_URL=$(echo $PROJECT | jq -r .path)
	PROJECT_BRANCH=$(echo $PROJECT | jq -r .branch)
	if [ $PROJECT_NAME != "optimus-libs" ] && [ $PROJECT_NAME != "optimus-container" ] && [ $PROJECT_NAME != "optimus-installer" ]
	then
		curl -f -s "$PROJECT_URL/-/raw/$PROJECT_BRANCH/manifest.json" -o /srv/services/$PROJECT_NAME.json
		echo -e "\e[0;35mTéléchargement du service $PROJECT_NAME\e[0m"
	fi
done