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
  
  output $OUTPUT_MODE "Recréation de l'enregistrement A racine" "magenta" 200 "letsencrypt_ovh" 30
  PUBLIC_IP=$( wget -qO- ipinfo.io/ip )
  verbose ovh_api_request "POST" "/domain/zone/$DOMAIN/record" '{"fieldType": "A", "target": "'$PUBLIC_IP'", "ttl": 0}'
  
  output $OUTPUT_MODE "Suppression des enregistrements MX" "magenta" 200 "letsencrypt_ovh" 40
  RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=MX")
  for RECORD in $(echo "$RECORDS" | jq -r '.[]')
  do
    verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
  done
  
  output $OUTPUT_MODE "Suppression des enregistrements SRV" "magenta" 200 "letsencrypt_ovh" 50
  RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=SRV")
  for RECORD in $(echo "$RECORDS" | jq -r '.[]')
  do
    verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
  done
  
  output $OUTPUT_MODE "Suppression des enregistrements CNAME" "magenta" 200 "letsencrypt_ovh" 60
  RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=CNAME")
  for RECORD in $(echo "$RECORDS" | jq -r '.[]')
  do
    verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
  done
  
  output $OUTPUT_MODE "Suppression des enregistrements TXT" "magenta" 200 "letsencrypt_ovh" 70
  RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=TXT")
  for RECORD in $(echo "$RECORDS" | jq -r '.[]')
  do
    verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
  done

  sleep 1
  
  output $OUTPUT_MODE "Rechargement de la zone DNS" "magenta" 200 "letsencrypt_ovh" 80
  verbose ovh_api_request "POST" "/domain/zone/$DOMAIN/refresh"

  output $OUTPUT_MODE "Génération d'un certificat wildcard pour le domaine $DOMAIN" "magenta" 200 "letsencrypt_ovh" 90
  echo "dns_ovh_endpoint = ovh-eu" > /root/ovh
  echo "dns_ovh_application_key = $OVH_APP_KEY" >> /root/ovh
  echo "dns_ovh_application_secret = $OVH_SECRET_KEY" >> /root/ovh
  echo "dns_ovh_consumer_key = $OVH_CONSUMER_KEY" >> /root/ovh
  verbose chmod 600 /root/ovh
  verbose certbot certonly --expand --non-interactive --agree-tos --quiet --email postmaster@$DOMAIN --dns-ovh --dns-ovh-propagation-seconds 30 --dns-ovh-credentials /root/ovh -d $DOMAIN -d *.$DOMAIN

  #output $OUTPUT_MODE "Ouverture du port 443 dans le firewall" "magenta" 200 "letsencrypt_ovh" 95
  #if [ $(which /sbin/ufw) ]
  #then 
  #  verbose /sbin/ufw allow 443
  #fi

  output $OUTPUT_MODE "Les certificats ont été valablement générés" "green" 200 "letsencrypt_ovh" 100

else
  output $OUTPUT_MODE "Les certificats SSL ont déjà été générés !" "red" 200 "letsencrypt_ovh" 100
fi