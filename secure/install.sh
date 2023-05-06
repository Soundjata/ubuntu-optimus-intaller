#!/bin/bash
source /etc/optimus/functions.sh
. /etc/os-release
if [ -z $DOMAIN ]; then require DOMAIN string "Veuillez renseigner votre nom de domaine :"; source /root/.optimus; fi
if [ -z $MODULE_SECURE_UPDATE ]; then require MODULE_SECURE_UPDATE yesno "Voulez vous mettre à jour le système -> update/upgrade ?"; source /root/.optimus; fi
if [ -z $MODULE_SECURE_ENABLEFW ]; then require MODULE_SECURE_ENABLEFW yesno "Voulez vous installer le pare-feu UFW ?"; source /root/.optimus; fi
if [ -z $MODULE_SECURE_FAIL2BAN ]; then require MODULE_SECURE_FAIL2BAN yesno "Voulez vous installer FAIL2BAN ?"; source /root/.optimus; fi
if [ -z $MODULE_SECURE_CHANGEROOTPASS ]; then require MODULE_SECURE_CHANGEROOTPASS yesno "Voulez vous modifier le mot de passe root ?"; source /root/.optimus; fi
if [ -z $MODULE_SECURE_CHANGEDEBIANPASS ]; then require MODULE_SECURE_CHANGEDEBIANPASS yesno "Voulez vous modifier le mot de passe de l'utilisateur '$ID' ?"; source /root/.optimus; fi
if [ -z $MODULE_SECURE_SSH_REPLACEDEFAULTPORT ]; then require MODULE_SECURE_SSH_REPLACEDEFAULTPORT yesno "Voulez vous remplacer le port de connexion SSH par le port 7822 ?"; source /root/.optimus; fi
if [ -z $MODULE_SECURE_SSH_PORTKNOCKING ]; then require MODULE_SECURE_SSH_PORTKNOCKING yesno "Voulez vous protéger le serveur SSH avec une séquence de Port Knocking ?"; source /root/.optimus; fi
if [[ $MODULE_SECURE_SSH_PORTKNOCKING =~ ^[YyOo]$ ]] && [ -z $MODULE_SECURE_SSH_PORTKNOCKING_SEQUENCE ]; then require MODULE_SECURE_SSH_PORTKNOCKING_SEQUENCE string "Veuillez indiquer la séquence de Port Knocking (exemple : 1083,1080,1082,1075) :"; source /root/.optimus; fi
if [ -z $MODULE_SECURE_SSH_DISABLEROOTACCESS ]; then require MODULE_SECURE_SSH_DISABLEROOTACCESS yesno "Voulez vous interdire l'accès SSH à l'utilisateur root ?"; source /root/.optimus; fi
if [ -z $MODULE_SECURE_SSH_2FA ]; then require MODULE_SECURE_SSH_2FA yesno "Voulez vous protéger l'accès SSH avec une authentification à deux facteurs (authenticator) ?"; source /root/.optimus; fi
source /root/.optimus
source /etc/os-release

if [ $MODULE_SECURE_UPDATE = "Y" ]
then
  echo
  echo_green "==== MISE A JOUR DU SYSTEME ===="
  echo_magenta "Téléchargement et installation des mises à jour"
  apt-get -qq update
  apt-get -qq upgrade
fi

if [ $MODULE_SECURE_ENABLEFW = "Y" ]
then
  echo
  echo_green "==== PARE FEU ===="
  echo_magenta "Installation des paquets requis"
  verbose apt-get -qq install ufw
  echo_magenta "Ouverture du port SSH"
  if grep -q "Port 7822" /etc/ssh/sshd_config
  then
    verbose /sbin/ufw allow 7822
  else
    verbose /sbin/ufw allow 22
  fi
  echo_magenta "Activation du pare feu"
  verbose /sbin/ufw --force enable
else
  echo
  echo_green "==== PARE FEU ===="
  if [ $(which /sbin/ufw) ]
  then
    echo_magenta "Désactivation du firewall"
    verbose /sbin/ufw --force disable
  fi
fi

if [ $MODULE_SECURE_FAIL2BAN = "Y" ]
then
  echo
  echo_green "==== FAIL2BAN ===="
  echo_magenta "Installation des paquets requis"
  verbose apt-get -qq install fail2ban
  echo_magenta "Installation des prisons locales"
  envsubst '${DOMAIN}' < /etc/optimus/secure/jail.local > /etc/fail2ban/jail.local
  #commit suggéré sur le github fail2ban mais pas encore implémenté
  sed -i '/mdpr-ddos = lost connection after(?! DATA)/c\mdpr-ddos = (?:lost connection after(?! DATA) [A-Z]+|disconnect(?= from \S+(?: \S+=\d+)* auth=0/(?:[1-9]|\d\d+)))' /etc/fail2ban/filter.d/postfix.conf
  sed -i "s/example.com/$DOMAIN/g" /etc/hosts
  echo_magenta "Redémarrage des services"
  systemctl restart fail2ban
else
  echo
  echo_green "==== FAIL2BAN ===="
  echo_magenta "Désinstallation des paquets"
  verbose apt-get -qq remove fail2ban
fi

if [ $MODULE_SECURE_CHANGEROOTPASS = "Y" ]
then
  echo
  echo_green "==== MODIFICATION DU MOT DE PASSE ROOT ===="
  echo_magenta "Modification du mot de passe root"
  require SECURE_ROOT_PASSWORD password "Veuillez renseigner le nouveau mot de passe root :"
  source /root/.optimus
  echo "root:$SECURE_ROOT_PASSWORD" | chpasswd root
fi

if [ $MODULE_SECURE_CHANGEDEBIANPASS = "Y" ]
then
  echo
  echo_green "==== MODIFICATION DU MOT DE PASSE DE L'UTILISATEUR $ID ===="
  echo_magenta "Modification du mot de passe de l'utilisateur '$ID'"
  require SECURE_DEBIAN_PASSWORD password "Veuillez renseigner le nouveau mot de passe pour l'utilisateur '$ID' :"
  source /root/.optimus
  echo "$ID:$SECURE_DEBIAN_PASSWORD" | chpasswd $ID
fi


if [ $MODULE_SECURE_SSH_DISABLEROOTACCESS = "Y" ]
then
  echo
  echo_green "==== ACCESS SSH DE L'UTILISATEUR ROOT ===="
  if [ $(getent passwd $ID) ]
  then
    echo_magenta "Désactivation de l'accès SSH de l'utilisateur root"
    verbose sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
    verbose sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
    echo_magenta "Redémarrage des services"
    verbose systemctl restart ssh
  else
    echo_red "L'accès SSH de l'utilisateur root ne peut pas être désactivé si l'utilisateur $ID n'existe pas"
  fi
else
  echo_magenta "Résactivation de l'accès SSH de l'utilisateur root"
  verbose sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
  verbose sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
  echo_magenta "Redémarrage des services"
  verbose systemctl restart ssh
fi


if [ $MODULE_SECURE_SSH_PORTKNOCKING = "Y" ]
then
	echo
	echo_green "==== PROTECTION DU SERVEUR SSH AVEC UNE SEQUENCE DE PORT KNOCKING ===="
	echo_magenta "Installation des paquets requis"
	verbose apt-get -qq install knockd
	echo_magenta "Modification des fichiers de configuration"
	envsubst '${MODULE_SECURE_SSH_PORTKNOCKING_SEQUENCE}' < /etc/optimus/secure/knockd.conf > /etc/knockd.conf
	if [ $MODULE_SECURE_SSH_REPLACEDEFAULTPORT = "Y" ]
	then
		verbose sed -i 's/22/7822/g' /etc/knockd.conf
	fi
	verbose sed -i 's/START_KNOCKD=0/START_KNOCKD=1/g' /etc/default/knockd
	#Modification nécessaire pour rendre knockd compatible avec UFW mais qui devrait être intégrée nativement dans la prochaine version de knockd
	verbose sed -i 's/ProtectSystem=full/ProtectSystem=true/g' /lib/systemd/system/knockd.service
	echo_magenta "Redémarrage du service"
	if ! grep -q "\[Install\]" /lib/systemd/system/knockd.service
	then
		echo -e "\n[Install]\nWantedBy=multi-user.target\n" >> /lib/systemd/system/knockd.service
	fi
	verbose systemctl daemon-reload
	verbose systemctl restart knockd
	verbose systemctl --quiet enable knockd.service
	echo_magenta "Fermeture du port SSH"
	if [ $MODULE_SECURE_SSH_REPLACEDEFAULTPORT = "Y" ]
	then
		verbose /sbin/ufw deny 7822
	else
		verbose /sbin/ufw deny 22
	fi
fi


if [ $MODULE_SECURE_SSH_2FA = "Y" ]
then
	echo
	echo_green "==== SECURISATION DE L'ACCESS SSH AVEC UN CODE A DEUX FACTEURS ===="

	if [ -z $DOMAIN ]; then require DOMAIN string "Veuillez indiquer votre nom de domaine :"; source /root/.optimus; fi

	echo_magenta "Installation des paquets requis"
	verbose apt-get -qq -y install libpam-google-authenticator qrencode ntp

	echo_magenta "Activation de l'authentification à deux facteurs"
	if ! grep -q "auth required pam_google_authenticator.so" /etc/pam.d/sshd
	then
		echo 'auth required pam_google_authenticator.so' >> /etc/pam.d/sshd
	fi
	verbose sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config

	#if ! grep -q "Accepted password for $ID from $SSH_CLIENT_IP" /var/log/auth.log
	#then
		#if ! grep -q "Match User $ID" /etc/ssh/sshd_config
		#then
			#verbose sed -i 's/@include common-auth/#@include common-auth/g' /etc/pam.d/sshd
			#echo -e "Match User $ID\nAuthenticationMethods publickey,keyboard-interactive\n" >> /etc/ssh/sshd_config
		#fi
	#fi

	if [ ! -f /root/.google_authenticator ]
	then
		echo_magenta "Génération des clés d'accès"
		google-authenticator --time-based --force --quiet --disallow-reuse --window-size=3 --rate-limit=3 --rate-time=30 --emergency-codes=4 --label=$ID@$DOMAIN --issuer=OPTIMUS
		update_conf SECURE_GOOGLEAUTH_KEY $(cat /root/.google_authenticator | head -1)

		echo_magenta "Copie des codes d'accès dans les paramètres de l'utilisateur $ID"
		if [ -d "/home/$ID" ]
		then
			verbose cp /root/.google_authenticator /home/$ID/.google_authenticator
		verbose chown $ID:$ID /home/$ID/.google_authenticator
		fi
	fi

	echo_magenta "Redémarrage des services"
	verbose systemctl restart sshd

else

	echo
	echo_green "==== SECURISATION DE L'ACCESS SSH AVEC UN CODE A DEUX FACTEURS ===="
	echo_magenta "Désactivation de l'authentification à deux facteurs"
	verbose sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
	verbose sed -i 's/#@include common-auth/@include common-auth/g' /etc/pam.d/sshd
	verbose rm /root/.google_authenticator
	verbose rm /home/$ID/.google_authenticator
	echo_magenta "Redémarrage des services"
	verbose systemctl restart sshd

fi


if [ ! -f /root/.google_authenticator ]
then
  echo_magenta "L'accès SSH est sécurisé par le code 2FA GOOGLE AUTHENTICATOR suivant :"
  qrencode -t ansi "otpauth://totp/$ID@demoptimus.fr?secret=$(cat /root/.google_authenticator | head -1)&issuer=OPTIMUS"
fi


if [ $MODULE_SECURE_SSH_REPLACEDEFAULTPORT = "Y" ]
then
  echo
  echo_green "==== PORT DU SERVEUR SSH ===="
  echo_magenta "Remplacement du port 22 par le port 7822"
  verbose sed -i 's/#Port 22/Port 7822/g' /etc/ssh/sshd_config
  echo_magenta "Ouverture du port 7822 et fermeture du port 22"
  if [ $(which /sbin/ufw) ]
  then
    verbose /sbin/ufw allow 7822
    verbose /sbin/ufw deny 22
  fi
  #echo_magenta "Redémarrage des services"
  #verbose systemctl restart ssh
else
  echo
  echo_green "==== PORT DU SERVEUR SSH ===="
  echo_magenta "Remplacement du port 7822 par le port 22"
  verbose sed -i 's/Port 7822/#Port 22/g' /etc/ssh/sshd_config
  echo_magenta "Ouverture du port 22 et fermeture du port 7822"
  if [ $(which /sbin/ufw) ]
  then
    verbose /sbin/ufw deny 7822
    verbose /sbin/ufw allow 22
  fi
  echo_magenta "Redémarrage des services"
  verbose systemctl restart ssh
fi