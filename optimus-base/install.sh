#!/bin/bash
source /etc/optimus/functions.sh

IMAGE="git.cybertron.fr:5050/optimus/optimus-base/v5:stable"
source /etc/optimus/optimus-init/container_installer.sh

if [ $OUTPUT_MODE != "json" ]
then 
	echo
	source /etc/optimus/create_admin/install.sh
fi
