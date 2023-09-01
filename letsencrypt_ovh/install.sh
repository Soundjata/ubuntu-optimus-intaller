#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DES CERTIFICATS SSL" "blue" 200 "letsencrypt_ovh" 0

if [ ! -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]
then

	output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "letsencrypt_ovh" 10
	verbose apt -qq -y install python3-pip python3-certbot python3-certbot-dns-ovh

	output $OUTPUT_MODE "Suppression des enregistrements A" "magenta" 200 "letsencrypt_ovh" 20
	RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=A")
	for RECORD in $(echo "$RECORDS" | jq -r '.[]')
	do
		verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
	done

	output $OUTPUT_MODE "Suppression des enregistrements MX" "magenta" 200 "letsencrypt_ovh" 25
	RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=MX")
	for RECORD in $(echo "$RECORDS" | jq -r '.[]')
	do
		verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
	done

	output $OUTPUT_MODE "Suppression des enregistrements SRV" "magenta" 200 "letsencrypt_ovh" 30
	RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=SRV")
	for RECORD in $(echo "$RECORDS" | jq -r '.[]')
	do
		verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
	done

	output $OUTPUT_MODE "Suppression des enregistrements CNAME" "magenta" 200 "letsencrypt_ovh" 35
	RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=CNAME")
	for RECORD in $(echo "$RECORDS" | jq -r '.[]')
	do
		verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
	done

	output $OUTPUT_MODE "Suppression des enregistrements TXT" "magenta" 200 "letsencrypt_ovh" 40
	RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=TXT")
	for RECORD in $(echo "$RECORDS" | jq -r '.[]')
	do
		verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
	done

	output $OUTPUT_MODE "Suppression des enregistrements DKIM" "magenta" 200 "letsencrypt_ovh" 45
	RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=DKIM")
	for RECORD in $(echo "$RECORDS" | jq -r '.[]')
	do
		verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
	done

	output $OUTPUT_MODE "Suppression des enregistrements SPF" "magenta" 200 "letsencrypt_ovh" 50
	RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=SPF")
	for RECORD in $(echo "$RECORDS" | jq -r '.[]')
	do
		verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
	done

	PUBLIC_IP=$( wget -qO- ipinfo.io/ip )
	output $OUTPUT_MODE "Recréation de l'enregistrement A racine" "magenta" 200 "letsencrypt_ovh" 55
	ovh_dns_record_replace "A" "" "$PUBLIC_IP"

	output $OUTPUT_MODE "Création du sous domaine api" "magenta" 200 "letsencrypt_ovh" 60
	ovh_dns_record_replace "A" "api" "$PUBLIC_IP"

	output $OUTPUT_MODE "Création du sous domaine optimus" "magenta" 200 "letsencrypt_ovh" 65
	ovh_dns_record_replace "A" "optimus" "$PUBLIC_IP"

	sleep 1

	output $OUTPUT_MODE "Rechargement de la zone DNS" "magenta" 200 "letsencrypt_ovh" 70
	verbose ovh_api_request "POST" "/domain/zone/$DOMAIN/refresh"

	output $OUTPUT_MODE "Génération d'un certificat wildcard pour le domaine $DOMAIN" "magenta" 200 "letsencrypt_ovh" 80
	echo "dns_ovh_endpoint = ovh-eu" > /root/ovh
	echo "dns_ovh_application_key = $OVH_APP_KEY" >> /root/ovh
	echo "dns_ovh_application_secret = $OVH_SECRET_KEY" >> /root/ovh
  	echo "dns_ovh_consumer_key = $OVH_CONSUMER_KEY" >> /root/ovh
	verbose chmod 600 /root/ovh
	verbose certbot certonly --expand --non-interactive --agree-tos --quiet --email postmaster@$DOMAIN --dns-ovh --dns-ovh-propagation-seconds 30 --dns-ovh-credentials /root/ovh -d $DOMAIN -d *.$DOMAIN

	output $OUTPUT_MODE "Configuration du Reverse DNS" "magenta" 200 "letsencrypt_ovh" 90
	RECORDS=$(ovh_api_request "POST" "/ip/$PUBLIC_IP/reverse" '{"ipReverse": "'$PUBLIC_IP'", "reverse": "'$DOMAIN'."}')

	if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]
	then
		output $OUTPUT_MODE "Les certificats ont été valablement générés" "green" 200 "letsencrypt_ovh" 100
	else
		output $OUTPUT_MODE "Une erreur est survenue !" "red" 400 "letsencrypt_ovh" 100
	fi

else
	output $OUTPUT_MODE "Les certificats SSL ont déjà été générés !" "red" 200 "letsencrypt_ovh" 100
fi
