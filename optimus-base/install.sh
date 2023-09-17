#!/bin/bash
source /etc/optimus/functions.sh

NAME="optimus-base"
source /etc/optimus/optimus-init/container_installer.sh

if [ $OUTPUT_MODE != "JSON" ]
then 
	echo
	source /etc/optimus/create_admin/install.sh
fi