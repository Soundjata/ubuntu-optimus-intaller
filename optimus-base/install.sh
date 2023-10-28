#!/bin/bash
source /etc/optimus/functions.sh

verbose rm -f -R /srv/optimus/optimus-base
IMAGE="git.cybertron.fr:5050/optimus/optimus-base/v5"
source /etc/optimus/optimus-init/container_installer.sh

if [ $OUTPUT_MODE != "json" ]
then 
	echo
	source /etc/optimus/create_admin/install.sh
fi
