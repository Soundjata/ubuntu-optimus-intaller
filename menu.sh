#!/bin/bash
cd /
source /etc/optimus/functions.sh
source /root/.optimus

DOMAIN_TO_DNS=$( getent hosts $DOMAIN | awk '{ print $1 }' )
PUBLIC_IP=$( wget -qO- ipinfo.io/ip )
OPTIMUS_INSTALLER_VERSION=$( tail -n 1 /etc/optimus/VERSION )

while : ; do

clear

tput cup 2 	3; echo -ne  "\033[46;30m              OPTIMUS INSTALLER               \e[0m"
tput cup 3 	3; echo -ne  "\033[46;30m                   V$OPTIMUS_INSTALLER_VERSION                      \e[0m"

tput cup 5  3; if [ -n "$LAST_UPGRADE" ]; then echo_green "a. Mettre à jour le système (LASTUPGRADE : $LAST_UPGRADE)"; else echo_red "a. Mettre à jour le système"; fi

tput cup 7  3; if [ -n "$PART_TO_ENCRYPT" ] && lsblk -o NAME -n /dev/$PART_TO_ENCRYPT 2>/dev/null | grep -q $PART_TO_ENCRYPT; then echo_green "b. Créer une partition $PART_TO_ENCRYPT indépendante"; else echo_red "b. Créer une partition $PART_TO_ENCRYPT indépendante"; fi
tput cup 8  3; if /sbin/blkid /dev/$PART_TO_ENCRYPT 2>/dev/null | grep -q 'crypto_LUKS'; then echo_green "c. Activer le chiffrement sur la partition $PART_TO_ENCRYPT"; else echo_red "c. Activer le chiffrement sur la partition $PART_TO_ENCRYPT"; fi
tput cup 9  3; if lsblk -o MOUNTPOINT -n /dev/mapper/crypt$PART_TO_ENCRYPT 2>/dev/null | grep -q '/srv'; then echo_green "d. Déchiffrer la partition $PART_TO_ENCRYPT et la monter sur /srv"; else echo_red "d. Déchiffrer la partition $PART_TO_ENCRYPT et la monter sur /srv"; fi

tput cup 11  3; if [ "$DOMAIN_TO_DNS" = "$PUBLIC_IP" ]; then echo_green "e. Configurer le DNS du domaine"; else echo_red "e. Configurer le DNS du domaine"; fi
tput cup 12  3; if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then echo_green "f. Installer les certificats SSL"; else echo_red "f. Installer les certificats SSL"; fi
tput cup 13  3; if [ -d /etc/nginx ]; then echo_green "g. Installer NGINX"; else echo_red "g. Installer NGINX"; fi
tput cup 14  3; if [ -d /etc/docker ]; then echo_green "h. Installer DOCKER"; else echo_red "h. Installer DOCKER"; fi

tput cup 16  3; if [ -d /etc/docker ] && [ $( docker ps -a | grep optimus-databases | wc -l ) -gt 0 ]; then echo_green "i. Installer OPTIMUS DATABASES"; else echo_red "i. Installer OPTIMUS DATABASES"; fi
tput cup 17  3; if [ -d /etc/docker ] && [ $( docker ps -a | grep optimus-base | wc -l ) -gt 0 ]; then echo_green "j. Installer OPTIMUS BASE"; else echo_red "j. Installer OPTIMUS BASE"; fi

tput cup 19  3; if [ -f /etc/ufw/applications.d/ufw-webserver ]; then echo_green "k. Installer le pare feu UFW"; else echo_red "k. Installer le pare feu UFW"; fi
tput cup 20  3; if [ -d /etc/fail2ban ]; then echo_green "l. Installer FAIL2BAN"; else echo_red "l. Installer FAIL2BAN"; fi
tput cup 21  3; if grep -q "Port 7822" /etc/ssh/sshd_config; then echo_green "m. Remplacer le port SSH par 7822"; else echo_red "m. Remplacer le port SSH par 7822"; fi
tput cup 22  3; if [ ! -z $DEBIAN_PASSWORD ]; then echo_green "n. Modifier le mot de passe de l'utilisateur debian"; else echo_red "n. Modifier le mot de passe de l'utilisateur debian"; fi
tput cup 23  3; if grep -q "auth required pam_google_authenticator.so" /etc/pam.d/sshd; then echo_green "o. Protéger le serveur SSH avec un 2FA"; else echo_red "o. Protéger le serveur SSH avec un 2FA"; fi

tput cup 25  3; if grep -q "$CYBERTRON_PUBLIC_KEY" /home/debian/.ssh/authorized_keys; then echo_green "p. Installer la clé publique CYBERTRON"; else echo_yellow "p. Installer la clé publique CYBERTRON"; fi
tput cup 26  3; if [ -f /etc/knockd.conf ]; then echo_green "q. Protéger le serveur avec une séquence de PORT KNOCKING"; else echo_yellow "q. Protéger le serveur avec une séquence de PORT KNOCKING"; fi
tput cup 27  3; if [ -d /etc/docker ] && [ $( docker ps -a | grep optimus-devtools | wc -l ) -gt 0 ]; then echo_green "r. Installer les outils de développement"; else echo_yellow "r. Installer les outils de développement"; fi

tput cup 29 3; echo_cyan "s. Sauvegarder la configuration et les clés de chiffrement"

tput cup 31 3; echo_cyan "t. Editer la configuration"
tput cup 32 3; echo_cyan "u. Mettre à jour Optimus Installer"
tput cup 33 3; echo_cyan "v. Redémarrer le serveur"
tput cup 34 3; echo_cyan "w. Afficher le QR CODE 2FA"
tput cup 35 3; echo_cyan "x. Quitter"

tput cup 37 3; echo_cyan "z. INSTALLATION AUTOMATISEE OVH"

tput cup 39 3; echo -ne "\033[46;30m Select Option : \e[0m"; tput cup 25 21

if [ -d /etc/docker ] && [ $( docker ps -a | grep optimus-devtools | wc -l ) -gt 0 ]
then
  tput cup 41 3; echo "1. Compilation des conteurs (DEV)"
  tput cup 42 3; echo "2. Affichage des logs d'erreur des conteneurs (DEV)"
fi

tput cup 44 3; echo_magenta "Il est rappelé que le logiciel OPTIMUS et ses composants sont des logiciels libres."
tput cup 45 3; echo_magenta "Le texte complet de la licence GNU AGPL V3 est fourni dans le fichier LICENSE ou consultable en tapant [ESPACE]."
tput cup 46 3; echo_magenta "Cela signifie que vous les utilisez sous votre seule et unique responsabilité."
tput cup 47 3; echo_magenta "Personne ne peut être tenu pour responsable d'un quelconque dommage, notamment lié à une perte de vos données"

read -n 1 y

case "$y" in

  a)
	tput reset
	clear
	source /etc/optimus/upgrade/install.sh
	source /root/.optimus
	read -p "Appuyez sur [ENTREE] pour continuer..."
		;;

  b)
	tput reset
	clear
	source /etc/optimus/diskpart/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  c)
  	tput reset
  	clear
  	source /etc/optimus/crypt/install.sh
  	read -p "Appuyez sur [ENTREE] pour continuer..."
  	;;

  d)
	tput reset
	clear
	source /etc/optimus/decrypt/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  e)
	tput reset
	clear
	source /etc/optimus/zonedns/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  f)
	tput reset
	clear
	  source /etc/optimus/letsencrypt/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;
  
  g)
	tput reset
	clear
	source /etc/optimus/nginx/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  h)
	tput reset
	clear
	source /etc/optimus/docker/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  i)
	tput reset
	clear
	source /etc/optimus/optimus-databases/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  j)
	tput reset
	clear
	source /etc/optimus/optimus-base/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  j)
	tput reset
	clear
	source /etc/optimus/optimus-base/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  k)
	tput reset
	clear
	source /etc/optimus/firewall/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  l)
	tput reset
	clear
	source /etc/optimus/fail2ban/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  m)
	tput reset
	clear
	source /etc/optimus/ssh_port_change/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  n)
	tput reset
	clear
	source /etc/optimus/debian_password/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  o)
	tput reset
	clear
	source /etc/optimus/2fa/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  p)
	tput reset
	clear
	source /etc/optimus/cybertron_ssh_key/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  q)
	tput reset
	clear
	source /etc/optimus/port_knocking/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  r)
	tput reset
	clear
	source /etc/optimus/optimus-devtools/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  s)
	tput reset
	clear
	source /etc/optimus/saveconfig/install.sh
	;;

  t)
	tput reset
	clear
	nano /root/.optimus
	source /etc/optimus/menu.sh
	;;

  u)
	tput reset
	clear
	source /etc/optimus/update/install.sh
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  v)
	tput reset
	reboot
	exit 1
	;;

  w)
	tput reset
	qrencode -t ansi "otpauth://totp/debian@$DOMAIN?secret=${SECURE_GOOGLEAUTH_KEY}&issuer=optimus"
	echo
	echo_magenta "Ce code doit être scanné et conservé sur votre smartphone à l'aide d'une application comme GOOGLE Authenticator, 2FAS ou Authy (gratuit)"
	echo_magenta "Ces applications permettent de générer un mot de passe qui change toutes les 30 secondes et qui vous sera demandé pour vous authentifier sur le serveur"
	echo
	read -p "Appuyez sur [ENTREE] pour continuer..."
	;;

  x)
	tput reset
	clear
	exit 1
	;;

  z)
	tput reset
	clear
	
	if [ -z $DOMAIN ]; then require DOMAIN string "Veuillez indiquer votre nom de domaine :"; source /root/.optimus; fi
	if [ -z $OVH_APP_KEY ]; then require OVH_APP_KEY string "Merci de renseigner votre clé OVH APPLICATION KEY"; source /root/.optimus; fi
	if [ -z $OVH_SECRET_KEY ]; then require OVH_SECRET_KEY string "Merci de renseigner votre clé OVH SECRET KEY"; source /root/.optimus; fi
	if [ -z $OVH_CONSUMER_KEY ]; then require OVH_CONSUMER_KEY string "Merci de renseigner votre clé OVH CONSUMER KEY"; source /root/.optimus; fi
	clear
	source /etc/optimus/upgrade/install.sh
  	source /etc/optimus/diskpart/install.sh
	source /etc/optimus/crypt/install.sh
	source /etc/optimus/letsencrypt/install.sh
	source /etc/optimus/nginx/install.sh
	source /etc/optimus/docker/install.sh
	source /etc/optimus/optimus-databases/install.sh
	source /etc/optimus/optimus-base/install.sh
	source /etc/optimus/create_admin/install.sh
	source /etc/optimus/firewall/install.sh
	source /etc/optimus/fail2ban/install.sh
	source /etc/optimus/ssh_port_change/install.sh
	source /etc/optimus/debian_password/install.sh
	source /etc/optimus/2fa/install.sh
	source /etc/optimus/create_admin/install.sh
	clear
	qrencode -t ansi "otpauth://totp/debian@$DOMAIN.fr?secret=${TWO_FA_KEY}&issuer=optimus"
	echo
	echo_magenta "Ce code doit être scanné et conservé sur votre smartphone à l'aide d'une application comme GOOGLE Authenticator, 2FAS ou Authy (gratuit)"
	echo_magenta "Ces applications permettent de générer un mot de passe qui change toutes les 30 secondes et qui vous sera demandé pour vous authentifier sur le serveur"
	echo
	read -p "Appuyez sur [ENTREE] pour continuer..."
	clear
	echo
	echo_magenta "Il est rappelé que les outils OPTIMUS sont des logiciels libres."
	echo_magenta "Le texte complet de la licence GNU AGPL V3 est fourni dans le fichier LICENSE ou consultable sur https://git.cybertron.fr/optimus/optimus-installer/-/raw/master/LICENSE"
	echo_magenta "Cela signifie que vous les utilisez sous votre seule et unique responsabilité."
	echo_magenta "Personne ne peut être tenu pour responsable d'un quelconque dommage, notamment lié à une perte de vos données"
	echo "APPUYER SUR [ENTREE] POUR CONTINUER"
	read -p ""
	clear
	source /etc/optimus/saveconfig/install.sh
	clear
	echo_magenta "Un redémarrage est nécessaire pour finaliser l'installation"
	echo_magenta "Avant toute utilisation vérifiez bien que vous parvenez toujours à accéder au serveur via SSH après le redémarrage"
	echo_magenta "Si vous avez choisi de renforcer la sécurité en modifiant le port SSH, rappelez vous que la connexion se fait désormais via le port 7822"
	echo_magenta "Si vous avez choisi de renforcer la sécurité en ajoutant une authentification 2FA, vérifiez bien que l'accès fonctionne"
	echo_magenta "Après le redémarrage du serveur, vérifiez que la partition chiffrée a bien été ouverte (option 'd' du menu en vert)"
	echo "APPUYER SUR [ENTREE] POUR CONTINUER"optimus-devtools
	  read -p ""
	echo
	echo_green "Si l'installation s'est bien déroulée, vous pourrez vous connecter à https://optimus.$DOMAIN"
	echo_green "Le serveur à renseigner est : api.$DOMAIN"
	echo_green "Les identifiants de connexion sont : $ADMIN_EMAIL_PREFIX@$DOMAIN / $ADMIN_PASSWORD"
	echo "APPUYER SUR [ENTREE] POUR REDEMARRER"
	read -p ""
	reboot
	;;

  1)
	tput reset
	clear
	source /etc/optimus/optimus-devtools/build.sh
	;;

  2)
	tput reset
	clear
	watch -n 1 'docker ps --format "{{.Names}}" | grep optimus- | grep --invert-match optimus-databases | sort | xargs --verbose --max-args=1 -- docker logs --tail=10 --timestamps'
	;;

  '')
	clear
	more -d /etc/optimus/LICENSE
	;;
	
esac
done
