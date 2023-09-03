#!/bin/bash
source /etc/optimus/functions.sh
if [ -z $DOMAIN ]; then require DOMAIN string "Veuillez indiquer votre nom de domaine :"; source /root/.optimus; fi
source /root/.optimus

echo
echo_green "==== ZONE DNS ===="
echo

verbose apt-get -qq install dnsutils

PUBLIC_IP=$( wget -qO- ipinfo.io/ip )
NSALL=$( dig NS $DOMAIN +short +retry=99 )
NSALL=(${NSALL[@]})
NS1="${NSALL[0]}"
NS2="${NSALL[1]}"
THEDATE=$(  date +"%Y%m%d" );

echo_magenta "Voici les enregistrements DNS à renseigner pour votre nom de domaine $DOMAIN si votre registrar est GANDI :"
echo

#if [ -d /srv/www ]; then echo "@ 3600 IN A $PUBLIC_IP"; fi
echo "api 3600 IN A $PUBLIC_IP"
echo "optimus 3600 IN A $PUBLIC_IP"
#if [ -d /srv/cloud ]; then echo "cloud 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/mailboxes ]; then echo "mail 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/shared ]; then echo "partage 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/webmail ]; then echo "webmail 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/www ]; then echo "www 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/mailboxes ]
#then
#   echo "@ 3600 IN MX 50 mail.$DOMAIN."
#   echo '@ 3600 IN TXT "v=spf1 mx ~all"'
#   echo '_dmarc TXT "v=DMARC1;p=quarantine;sp=quarantine;pct=100;adkim=r;aspf=r;fo=1;ri=86400;rua=mailto:postmaster@'$DOMAIN';ruf=mailto:postmaster@'$DOMAIN';rf=afrf"'
#   sed -e 's/IN/3600 IN/g' -e ':a;N;$!ba;s/\n/\ /g' -e 's/\t/ /g' /etc/dkim/keys/$DOMAIN/mail.txt
#fi

echo
echo_magenta "Voici les enregistrements DNS à renseigner pour votre nom de domaine $DOMAIN si votre registrar est OVH :"
echo_magenta "Il faut copier le texte ci-dessous dans la rubrique Web Cloud --> Domaines --> $DOMAIN --> Zone DNS --> Modifier en mode textuel";
echo_magenta "Attention car OVH exige que le texte collé se termine par un saut de ligne (touche ENTREE)"
echo

echo '$TTL 3600';
echo "@	IN SOA $NS2 tech.ovh.net. ($THEDATE 86400 3600 3600000 60)";
echo "	3600 IN NS $NS2";
echo "	3600 IN NS $NS1";
#if [ -d /srv/www ]; then echo "	3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/mailboxes ]; then echo "	3600 IN MX 50 mail.$DOMAIN."; fi
#if [ -d /srv/mailboxes ]; then echo '	3600 IN TXT "v=spf1 mx ~all"'; fi
#if [ -d /srv/mailboxes ]; then echo '_dmarc 3600 IN TXT "v=DMARC1;p=quarantine;sp=quarantine;pct=100;adkim=r;aspf=r;fo=1;ri=86400;rua=mailto:postmaster@'$DOMAIN';ruf=mailto:postmaster@'$DOMAIN';rf=afrf"'; fi
#if [ -d /srv/mailboxes ]; then sed -e 's/IN/3600 IN/g' -e ':a;N;$!ba;s/\n/\ /g' -e 's/\t/ /g' /etc/dkim/keys/$DOMAIN/mail.txt; fi
echo "api 3600 IN A $PUBLIC_IP"
echo "optimus 3600 IN A $PUBLIC_IP"
#if [ -d /srv/api ]; then echo "api 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/cloud ]; then echo "cloud 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/mailboxes ]; then echo "mail 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/shared ]; then echo "partage 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/webmail ]; then echo "webmail 3600 IN A $PUBLIC_IP"; fi
#if [ -d /srv/www ]; then echo "www 3600 IN A $PUBLIC_IP"; fi


# if [ -d /srv/mailboxes ]
# then
#   echo
#   echo_magenta "Pour le bon fonctionnement du serveur mail, il faut également renseigner le 'REVERSE DNS' de votre serveur : $DOMAIN"
# fi


echo
echo_magenta "Si vous hébergez vous même votre serveur, ces ports doivent être redirigés vers votre serveur :"
echo ""
if grep -q "Port 7822" /etc/ssh/sshd_config
then
  echo "7822 SSH"
else
  echo "22   SSH"
fi

echo "80   HTTP"
echo "443  HTTPS"

#if [ -d /srv/mailboxes ]
#then
  #echo "25   SMTP"
  #echo "143  IMAP"
  #echo "465  SMTPS"
  #echo "587  SMTPS"
  #echo "993  IMAPS"
#fi

#if [ -d /srv/databases ]; then echo "3306 MYSQL"; fi

echo
