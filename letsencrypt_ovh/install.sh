#!/bin/bash
source /etc/optimus/functions.sh
if [ -z $DOMAIN ]; then require DOMAIN string "Veuillez indiquer votre nom de domaine :"; source /root/.optimus; fi
if [ -z $MODULE_LETSENCRYPT_OVH ]; then require MODULE_LETSENCRYPT_OVH yesno "Voulez-vous générer des certificats SSL pour sécuriser les communications ?"; source /root/.optimus; fi
if [ -z $MODULE_CLEANDNS_OVH ]; then require MODULE_CLEANDNS_OVH yesno "Voulez-vous supprimer les enregistrements DNS inutiles sur $DOMAIN ?"; source /root/.optimus; fi
if [ -z $OVH_APP_KEY ]; then require OVH_APP_KEY string "Merci de renseigner votre clé OVH APPLICATION KEY"; source /root/.optimus; fi
if [ -z $OVH_SECRET_KEY ]; then require OVH_SECRET_KEY string "Merci de renseigner votre clé OVH SECRET KEY"; source /root/.optimus; fi
if [ -z $OVH_CONSUMER_KEY ]; then require OVH_CONSUMER_KEY string "Merci de renseigner votre clé OVH CONSUMER KEY"; source /root/.optimus; fi

source /root/.optimus

if [ $MODULE_CLEANDNS_OVH = "Y" ]
then
  echo
  echo_green "==== REINITIALISATION DE LA ZONE DNS ===="

  echo_magenta "Suppression des enregistrements A"
  RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=A")
  for RECORD in $(echo "$RECORDS" | jq -r '.[]')
  do
    verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
  done

  echo_magenta "Recréation de l'enregistrement A racine"
  verbose ovh_api_request "POST" "/domain/zone/$DOMAIN/record" '{"fieldType": "A", "target": "'$PUBLIC_IP'", "ttl": 0}'
  
  echo_magenta "Suppression des enregistrements MX"
  RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=MX")
  for RECORD in $(echo "$RECORDS" | jq -r '.[]')
  do
    verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
  done

  echo_magenta "Suppression des enregistrements SRV"
  RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=SRV")
  for RECORD in $(echo "$RECORDS" | jq -r '.[]')
  do
    verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
  done

  echo_magenta "Suppression des enregistrements CNAME"
  RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=CNAME")
  for RECORD in $(echo "$RECORDS" | jq -r '.[]')
  do
    verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
  done

  echo_magenta "Suppression des enregistrements TXT"
  RECORDS=$(ovh_api_request "GET" "/domain/zone/$DOMAIN/record?fieldType=TXT")
  for RECORD in $(echo "$RECORDS" | jq -r '.[]')
  do
    verbose ovh_api_request "DELETE" "/domain/zone/$DOMAIN/record/$RECORD"
  done

   verbose ovh_api_request "POST" "/domain/zone/$DOMAIN/refresh"
fi


if [ $MODULE_LETSENCRYPT_OVH = "Y" ]
then
  if [ ! -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]
  then
    echo
    echo_green "==== INSTALLATION DES CERTIFICATS SSL LETSENCRYPT ===="

    echo_magenta "Installation des paquets requis"
    verbose apt-get -qq -y install python3-pip
    verbose pip install certbot
    verbose pip install certbot-dns-ovh

    echo_magenta "Génération d'un certificat wildcard pour le domaine $DOMAIN"
    echo "dns_ovh_endpoint = ovh-eu" > /root/ovh
    echo "dns_ovh_application_key = $OVH_APP_KEY" >> /root/ovh
    echo "dns_ovh_application_secret = $OVH_SECRET_KEY" >> /root/ovh
    echo "dns_ovh_consumer_key = $OVH_CONSUMER_KEY" >> /root/ovh
    verbose chmod 600 /root/ovh
    verbose certbot certonly --expand --non-interactive --agree-tos --quiet --email postmaster@$DOMAIN --dns-ovh --dns-ovh-propagation-seconds 30 --dns-ovh-credentials /root/ovh -d $DOMAIN -d *.$DOMAIN

    echo_magenta "Ouverture du port 443 dans le firewall"
    if [ $(which /sbin/ufw) ]
    then 
      verbose /sbin/ufw allow 443
    fi

  else
    echo_magenta "Les certificats SSL ont déjà été générés !"
  fi

fi

