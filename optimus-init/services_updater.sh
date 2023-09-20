#!/bin/bash

OPTIMUS_REPO=$(curl -s https://git.cybertron.fr/api/v4/groups/optimus/projects?search=optimus-&simple=true)

PROJECTS=$(echo $OPTIMUS_REPO | jq -c '.[] | {name: .name, path: .web_url, branch: .default_branch}')
for PROJECT in $PROJECTS
do
	PROJECT_NAME=$(echo $PROJECT | jq -r .name)
	PROJECT_URL=$(echo $PROJECT | jq -r .path)
	PROJECT_BRANCH=$(echo $PROJECT | jq -r .branch)
	if [ ! -f "/srv/services/$PROJECT_NAME.json" ] && [ $PROJECT_NAME != "optimus-libs" ] && [ $PROJECT_NAME != "optimus-container" ] && [ $PROJECT_NAME != "optimus-installer" ]
	then
		curl -f -s "$PROJECT_URL/-/raw/$PROJECT_BRANCH/manifest.json" -o /srv/services/$PROJECT_NAME.json
		if [ -f "/srv/services/$PROJECT_NAME.json" ]
		then
			echo -e "\e[0;32m$PROJECT_NAME\e[0m"
		else
			echo -e "\e[0;31m$PROJECT_NAME\e[0m"
		fi
	fi
done