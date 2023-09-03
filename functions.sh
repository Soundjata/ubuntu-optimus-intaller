#!/bin/bash
OUTPUT_MODE="${1:-console}"
DEV_MODE="${2:-N}"
source /root/.optimus

function ovh_api_request()
{
	CONSUMER_KEY=$OVH_CONSUMER_KEY
	APP_KEY=$OVH_APP_KEY
	APP_SECRET=$OVH_SECRET_KEY
	CONTENT_TYPE='Content-Type:application/json;charset=utf-8'
	OVH_APP="X-Ovh-Application:${APP_KEY}"
	OVH_CONSUMER="X-Ovh-Consumer:${CONSUMER_KEY}"
	JSON2TEXT="python -mjson.tool"
	REQ_TYPE="$1"
	ENDPOINT="$2"
	DATA="$3"
	API_URL="https://api.ovh.com/1.0"
	TIMESTAMP=$(curl -s https://api.ovh.com/1.0/auth/time)
	OVH_TIMESTAMP="X-Ovh-Timestamp:${TIMESTAMP}"
	SIG_KEY="${APP_SECRET}+${CONSUMER_KEY}+${REQ_TYPE}+${API_URL}${ENDPOINT}+${DATA}+${TIMESTAMP}" 
	THE_SIG=$(echo "\$1\$$(echo -n "${SIG_KEY}" |sha1sum - | cut -d' ' -f1)")
	OVH_SIG="X-Ovh-Signature:$THE_SIG"
	
	curl -s -X "${REQ_TYPE}" \
	--header "${CONTENT_TYPE}" \
	--header "${OVH_TIMESTAMP}" \
	--header "${OVH_APP}" \
	--header "${OVH_SIG}" \
	--header "${OVH_CONSUMER}" \
	--data "${DATA}" \
	"${API_URL}${ENDPOINT}"
}

function ovh_dns_record_replace()
{
	RECORD_TYPE=$1
	SUBDOMAIN=$2
	TARGET=$3
	echo_magenta "Traitement des enregistrements $SUBDOMAIN.$DOMAIN"
	RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=A&subDomain=$SUBDOMAIN")
	RECORDS_LENGTH=$(echo $RECORDS | jq length)
	if [ $RECORDS_LENGTH -eq 1 ]
	then
		RECORD_ID=$(echo $RECORDS | jq .[0])
		RECORD=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record/$RECORD_ID")
		if [ $(echo $RECORD | jq .target) != '"'$TARGET'"' ]
		then
			verbose ovh_api_request "PUT" "/domain/zone/$DOMAIN/record/$RECORD_ID" '{"subDomain": "'$SUBDOMAIN'", "target": "'$TARGET'", "ttl": 0}'
			echo_magenta "--> 1 enregistrement modifié"
		else
			echo_magenta "--> 1 enregistrement maintenu"
		fi
	else
		for RECORD in $(echo "$RECORDS" | jq -r '.[]')
		do
			verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
			echo_magenta "--> 1 enregistrement supprimé"
		done
		verbose ovh_api_request "POST" "/domain/zone/$DOMAIN/record" '{"fieldType": "'$RECORD_TYPE'", "subDomain": "'$SUBDOMAIN'", "target": "'$TARGET'", "ttl": 0}'
		echo_magenta "--> 1 enregistrement créé"
	fi
}

function output()
{
  MODE="$1"
  MESSAGE="$2"
  COLOR="$3"
  STATUS="$4"
  OPERATION="$5"
  PROGRESS="$6"
  if [ $MODE = "json" ]
  then
    if [ ! -z "$MESSAGE" ]
    then
      echo '{"code":'$STATUS', "message":"'$MESSAGE'", "color":"'$COLOR'","operation":"'$OPERATION'", "progress":'$PROGRESS'}'
    fi
  elif [ $MODE = "console" ]
  then
    case $COLOR in
      red) echo -e "\e[31m$MESSAGE\e[0m"
      ;;
      green) echo -e "\e[32m$MESSAGE\e[0m"
      ;;
      yellow) echo -e "\e[33m$MESSAGE\e[0m"
      ;;
      blue) echo -e "\e[36m$MESSAGE\e[0m"
      ;;
      magenta) echo -e "\e[35m$MESSAGE\e[0m"
      ;;
    esac
  fi
}

echo_red()(echo -e "\e[31m${1}\e[0m")
echo_green()(echo -e "\e[32m${1}\e[0m")
echo_yellow()(echo -e "\e[33m${1}\e[0m")
echo_blue()(echo -e "\e[34m${1}\e[0m")
echo_magenta()(echo -e "\e[35m${1}\e[0m")
echo_cyan()(echo -e "\e[36m${1}\e[0m")


if [ ! -f /root/.optimus ]
then
	cp /etc/config.sh /root/.optimus
fi


verbose()
(
  if [ "$VERBOSE" = 1 ]
  then
    (set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1
  elif [ "$VERBOSE" = 2 ]
  then
    set -o pipefail;"$@" 2> >(sed $'s,.*,\e[31m&\e[m,'>&2) 1>/dev/null
  elif [ "$VERBOSE" = 3 ]
  then
    set -o pipefail;"$@" &>/dev/null
  fi
)


update_conf()
(
  if grep -q "$1=" /root/.optimus
  then
    verbose sed -i "/export $1=/c export $1=$2" /root/.optimus
  else
    echo "export $1=$2"  >> /root/.optimus
  fi
)


require()
(
  variable=${1}
  type=${2}
  question=${3}
  valeur=${4}

  if [ $type ] && [ $type = "uuid" ]
  then
    if [[ "${!variable}" = "auto" ]]
    then
      valeur=$(</dev/urandom tr -dc A-Z0-9 | head -c 16)
    elif [ -z ${!variable} ]
    then
      echo_green "$question"
      echo_green "Voulez-vous générer $variable automatiquement ?"
      while [ -z "$valeur" ]
      do
        read -p "(o)ui / (n)on ? " -n 1 -e valeur
        if [[ $valeur =~ ^[YyOo]$ ]]
        then
          valeur=$(</dev/urandom tr -dc A-Z0-9 | head -c 16)
        elif [[ $valeur =~ ^[nN]$ ]]
        then
          echo_green "Veuillez renseigner $variable :"
          read valeur
        else
          echo_red "Réponse invalide"
        fi
      done
    fi
  elif [ $type ] && [ $type = "password" ]
  then
    if [[ "${!variable}" = "auto" ]]
    then
      valeur=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 32)
    elif [ -z ${!variable} ]
    then
      echo_green "$question"
      echo_green "Voulez-vous générer $variable automatiquement ?"
      while [ -z "$valeur" ]
      do
        read -p "(o)ui / (n)on ? " -n 1 -e valeur
        if [[ $valeur =~ ^[YyOo]$ ]]
        then
          valeur=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 32)
        elif [[ $valeur =~ ^[nN]$ ]]
        then
          echo_green "Veuillez renseigner $variable :"
          read valeur
        else
          echo_red "Réponse invalide"
        fi
      done
    fi
  elif [ $type ] && [ $type = "aeskey" ]
  then
    if [[ "${!variable}" = "auto" ]]
    then
      valeur=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 16)
    elif [ -z ${!variable} ]
    then
      echo_green "$question"
      echo_green "Voulez-vous générer $variable automatiquement ?"
      while [ -z "$valeur" ]
      do
        read -p "(o)ui / (n)on ? " -n 1 -e valeur
        if [[ $valeur =~ ^[YyOo]$ ]]
        then
          valeur=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 16)
        elif [[ $valeur =~ ^[nN]$ ]]
        then
          echo_green "Veuillez renseigner $variable :"
          read valeur
        else
          echo_red "Réponse invalide"
        fi
      done
    fi
  elif [ $type ] && [ $type = "deskey" ]
  then
    if [[ "${!variable}" = "auto" ]]
    then
      valeur=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 24)
    elif [ -z ${!variable} ]
    then
      echo_green "$question"
      echo_green "Voulez-vous générer $variable automatiquement ?"
      while [ -z "$valeur" ]
      do
        read -p "(o)ui / (n)on ? " -n 1 -e valeur
        if [[ $valeur =~ ^[YyOo]$ ]]
        then
          valeur=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 24)
        elif [[ $valeur =~ ^[nN]$ ]]
        then
          echo_green "Veuillez renseigner $variable :"
          read valeur
        else
          echo_red "Réponse invalide"
        fi
      done
    fi
  elif [ -z ${!variable} ]
  then
    echo_green "$question"
    if [ $type = "yesno" ]
    then
      while [ -z "$valeur" ]
      do
        read -p "(o)ui / (n)on ? " -n 1 -e valeur
        if [[ $valeur =~ ^[YyOo]$ ]]
        then
          valeur="Y"
        elif [[ $valeur =~ ^[nN]$ ]]
        then
          valeur="N"
        else
          echo_red "Réponse invalide"
        fi
      done
    else
      read valeur
    fi
  fi

  if [ ! -z $valeur ]
  then
    update_conf $variable $valeur
  fi
)
