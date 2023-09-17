#!/bin/bash
#source /etc/optimus/functions.sh

echo
echo -e "\e[32m==== "${1^^}" ====\e[0m"
docker logs --tail=10 --timestamps $1
