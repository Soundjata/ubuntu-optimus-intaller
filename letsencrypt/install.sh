#!/bin/bash
source /etc/optimus/functions.sh
if [ -z $DOMAIN ]; then require DOMAIN string "Veuillez indiquer votre nom de domaine :"; source /root/.optimus; fi
source /root/.optimus

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DES CERTIFICATS SSL" "blue" 200 "letsencrypt" 0

if [ ! -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]
then

	if [ -z $OVH_APP_KEY ] && [ -z $OVH_SECRET_KEY ] && [ $OVH_CONSUMER_KEY ]
	then

		output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "letsencrypt" 10
		verbose apt -qq -y install python3-pip python3-certbot python3-certbot-dns-ovh 2> /dev/null

		output $OUTPUT_MODE "Suppression des enregistrements A" "magenta" 200 "letsencrypt" 20
		RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=A")
		for RECORD in $(echo "$RECORDS" | jq -r '.[]')
		do
			verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
		done

		output $OUTPUT_MODE "Suppression des enregistrements MX" "magenta" 200 "letsencrypt" 25
		RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=MX")
		for RECORD in $(echo "$RECORDS" | jq -r '.[]')
		do
			verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
		done

		output $OUTPUT_MODE "Suppression des enregistrements SRV" "magenta" 200 "letsencrypt" 30
		RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=SRV")
		for RECORD in $(echo "$RECORDS" | jq -r '.[]')
		do
			verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
		done

		output $OUTPUT_MODE "Suppression des enregistrements CNAME" "magenta" 200 "letsencrypt" 35
		RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=CNAME")
		for RECORD in $(echo "$RECORDS" | jq -r '.[]')
		do
			verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
		done

		output $OUTPUT_MODE "Suppression des enregistrements TXT" "magenta" 200 "letsencrypt" 40
		RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=TXT")
		for RECORD in $(echo "$RECORDS" | jq -r '.[]')
		do
			verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
		done

		output $OUTPUT_MODE "Suppression des enregistrements DKIM" "magenta" 200 "letsencrypt" 45
		RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=DKIM")
		for RECORD in $(echo "$RECORDS" | jq -r '.[]')
		do
			verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
		done

		output $OUTPUT_MODE "Suppression des enregistrements DMARC" "magenta" 200 "letsencrypt" 47
		RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=DMARC")
		for RECORD in $(echo "$RECORDS" | jq -r '.[]')
		do
			verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
		done

		output $OUTPUT_MODE "Suppression des enregistrements SPF" "magenta" 200 "letsencrypt" 50
		RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=SPF")
		for RECORD in $(echo "$RECORDS" | jq -r '.[]')
		do
			verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
		done

		PUBLIC_IP=$( wget -qO- ipinfo.io/ip )
		output $OUTPUT_MODE "Recréation de l'enregistrement A racine" "magenta" 200 "letsencrypt" 55
		ovh_dns_record_replace "A" "" "$PUBLIC_IP"

		output $OUTPUT_MODE "Création du sous domaine api" "magenta" 200 "letsencrypt" 60
		ovh_dns_record_replace "A" "api" "$PUBLIC_IP"

		output $OUTPUT_MODE "Création du sous domaine optimus" "magenta" 200 "letsencrypt" 65
		ovh_dns_record_replace "A" "optimus" "$PUBLIC_IP"

		sleep 1

		output $OUTPUT_MODE "Configuration du Reverse DNS" "magenta" 200 "letsencrypt" 90
		RECORDS=$(ovh_api_request "POST" "/ip/$PUBLIC_IP/reverse" '{"ipReverse": "'$PUBLIC_IP'", "reverse": "'$DOMAIN'."}')

		output $OUTPUT_MODE "Rechargement de la zone DNS" "magenta" 200 "letsencrypt" 70
		verbose ovh_api_request "POST" "/domain/zone/$DOMAIN/refresh"
		
		sleep 1

		output $OUTPUT_MODE "Génération d'un certificat wildcard pour le domaine $DOMAIN" "magenta" 200 "letsencrypt" 80
		echo "dns_ovh_endpoint = ovh-eu" > /root/ovh
		echo "dns_ovh_application_key = $OVH_APP_KEY" >> /root/ovh
		echo "dns_ovh_application_secret = $OVH_SECRET_KEY" >> /root/ovh
		echo "dns_ovh_consumer_key = $OVH_CONSUMER_KEY" >> /root/ovh
		verbose chmod 600 /root/ovh
		verbose certbot certonly --expand --non-interactive --agree-tos --quiet --email postmaster@$DOMAIN --dns-ovh --dns-ovh-propagation-seconds 30 --dns-ovh-credentials /root/ovh -d $DOMAIN -d *.$DOMAIN

	else

		echo_magenta "Installation des paquets requis"
		verbose apt -qq -y install letsencrypt python3-certbot-apache dnsutils 2> /dev/null

		PUBLIC_IP=$( wget -qO- ipinfo.io/ip )
		NSALL=$( dig NS $DOMAIN +short +retry=99 )
		NSALL=(${NSALL[@]})
		NS1="${NSALL[0]}"
		NS2="${NSALL[1]}"
		THEDATE=$(  date +"%Y%m%d" );

		echo_magenta "Voici les enregistrements DNS à renseigner pour votre nom de domaine $DOMAIN si votre registrar est GANDI :"
		echo

		echo "api 3600 IN A $PUBLIC_IP"
		echo "optimus 3600 IN A $PUBLIC_IP"

		echo
		echo_magenta "Voici les enregistrements DNS à renseigner pour votre nom de domaine $DOMAIN si votre registrar est OVH :"
		echo_magenta "Il faut copier le texte ci-dessous dans la rubrique Web Cloud --> Domaines --> $DOMAIN --> Zone DNS --> Modifier en mode textuel";
		echo_magenta "Attention car OVH exige que le texte collé se termine par un saut de ligne (touche ENTREE)"
		echo

		echo '$TTL 3600';
		echo "@	IN SOA $NS2 tech.ovh.net. ($THEDATE 86400 3600 3600000 60)";
		echo "	3600 IN NS $NS2";
		echo "	3600 IN NS $NS1";
		echo "api 3600 IN A $PUBLIC_IP"
		echo "optimus 3600 IN A $PUBLIC_IP"

		echo
		echo_magenta "Si vous hébergez vous même votre serveur, ces ports doivent être redirigés vers votre serveur :"
		echo
		if grep -q "Port 7822" /etc/ssh/sshd_config; then echo "7822 SSH"; else echo "22   SSH"; fi
		echo "80   HTTP"
		echo "443  HTTPS"

		echo "Une fois les modifications effectuées, appuyez sur [ENTREE] pour générer les certificats"
		read -p ""
		clear
		
		output $OUTPUT_MODE "Génération d'un certificat wildcard pour le domaine $DOMAIN" "magenta" 200 "letsencrypt" 66
		certbot run -n --apache --redirect --agree-tos --email postmaster@$DOMAIN -d $DOMAIN -d *.$DOMAIN

	fi

	if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]
	then
		output $OUTPUT_MODE "Les certificats ont été valablement générés" "green" 200 "letsencrypt" 100
	else
		output $OUTPUT_MODE "Une erreur est survenue !" "red" 400 "letsencrypt" 100
	fi

else
	output $OUTPUT_MODE "Les certificats SSL ont déjà été générés !" "red" 200 "letsencrypt" 100
fi