#!/bin/bash
cd /
source /etc/optimus/functions.sh
source /root/.optimus

#MENU OPENS ON REBOOT EXCEPT IN DEV MODE (because it hangs VSCODE and some SFTP CLIENTS)
#if [ $DEV -eq 1 ]
#then
  #sed -i '/sudo \/usr\/bin\/bash \/etc\/optimus\/menu.sh/d' /home/debian/.bashrc
#elif ! grep -q "sudo /usr/bin/bash /etc/optimus/menu.sh" /home/debian/.bashrc
#then
    #echo "sudo /usr/bin/bash /etc/optimus/menu.sh" >> /home/debian/.bashrc
#fi

DOMAIN_TO_DNS=$( getent hosts $DOMAIN | awk '{ print $1 }' )
PUBLIC_IP=$( wget -qO- ipinfo.io/ip )
OPTIMUS_INSTALLER_VERSION=$( tail -n 1 /etc/optimus/VERSION )

while : ; do

clear

tput cup 2 	3; echo -ne  "\033[46;30m          OPTIMUS INSTALLER          \e[0m"
tput cup 3 	3; echo -ne  "\033[46;30m                V$OPTIMUS_INSTALLER_VERSION                \e[0m"

tput cup 5  3; if [ -n "$LAST_UPGRADE" ]; then echo_green "a. Mettre à jour le système (LASTUPGRADE : $LAST_UPGRADE)"; else echo_red "a. Mettre à jour le système"; fi
tput cup 6  3; if [ -n "$PART_TO_ENCRYPT" ] && lsblk -o NAME -n /dev/$PART_TO_ENCRYPT 2>/dev/null | grep -q $PART_TO_ENCRYPT; then echo_green "b. Créer une partition $PART_TO_ENCRYPT indépendante"; else echo_red "b. Créer une partition $PART_TO_ENCRYPT indépendante"; fi
tput cup 7  3; if /sbin/blkid /dev/$PART_TO_ENCRYPT 2>/dev/null | grep -q 'crypto_LUKS'; then echo_green "c. Activer le chiffrement sur la partition $PART_TO_ENCRYPT"; else echo_red "c. Activer le chiffrement sur la partition $PART_TO_ENCRYPT"; fi
tput cup 8  3; if lsblk -o MOUNTPOINT -n /dev/mapper/crypt$PART_TO_ENCRYPT 2>/dev/null | grep -q '/srv'; then echo_green "d. Déchiffrer la partition $PART_TO_ENCRYPT et la monter sur /srv"; else echo_red "d. Déchiffrer la partition $PART_TO_ENCRYPT et la monter sur /srv"; fi
tput cup 9  3; if grep -q "Port 7822" /etc/ssh/sshd_config; then echo_green "e. Sécuriser le serveur"; else echo_red "e. Sécuriser le serveur"; fi

tput cup 11 3; if [ -f "/etc/letsencrypt/live/$DOMAIN/privkey.pem" ];  then echo_green "f. Installer les certificats SSL via OVH"; else echo_red "f. Installer les certificats SSL via OVH"; fi
tput cup 12 3; if [ -d "/etc/nginx/sites-enabled" ]; then echo_green "g. Installer NGINX"; else echo_red "g. Installer NGINX"; fi
tput cup 13 3; if [ -d "/etc/docker" ]; then echo_green "h. Installer DOCKER"; else echo_red "h. Installer DOCKER"; fi
tput cup 14 3; if [ -d "/srv/databases" ]; then echo_green "i. Installer le conteneur MARIADB"; else echo_red "i. Installer le conteneur MARIADB"; fi
tput cup 15 3; if [ -d "/srv/services" ]; then echo_green "j. Installer le conteneur OPTIMUS BASE"; else echo_red "j. Installer le conteneur OPTIMUS BASE"; fi

tput cup 19 3; if [ -f "/srv/optimus-backup.sh" ]; then echo_green "r. Installer les scripts de sauvegarde"; else echo_red "r. Installer les scripts de sauvegarde"; fi

tput cup 21 3; echo_green "s. Sauvegarder la configuration et les clés de chiffrement"

tput cup 23 3; echo_green "t. Editer la configuration"
tput cup 24 3; echo_green "u. Mettre à jour Optimus Installer"
tput cup 25 3; echo_green "v. Redémarrer le serveur"
tput cup 26 3; echo_green "w. Afficher le QR CODE 2FA"
tput cup 27 3; echo_green "x. Quitter"

tput cup 29 3; echo_green "y. INSTALLATION GUIDEE"
tput cup 30 3; echo_green "z. INSTALLATION AUTOMATISEE"

tput cup 32 3; echo -ne "\033[46;30m Select Option : \e[0m"; tput cup 25 21

tput cup 35 3; echo_magenta "Il est rappelé que le logiciel OPTIMUS et ses composants sont des logiciels libres."
tput cup 36 3; echo_magenta "Le texte complet de la licence GNU AGPL V3 est fourni dans le fichier LICENSE ou consultable en tapant [ESPACE]."
tput cup 37 3; echo_magenta "Cela signifie que vous les utilisez sous votre seule et unique responsabilité."
tput cup 38 3; echo_magenta "Personne ne peut être tenu pour responsable d'un quelconque dommage, notamment lié à une perte de vos données"

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
    source /etc/optimus/secure/install.sh
    read -p "Appuyez sur [ENTREE] pour continuer..."
    ;;

  f)
    tput reset
    clear
	source /etc/optimus/letsencrypt_ovh/install.sh
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
    source /etc/optimus/mariadb/install.sh
    read -p "Appuyez sur [ENTREE] pour continuer..."
    ;;

  j)
    tput reset
    clear
    source /etc/optimus/optimus_base/install.sh
    read -p "Appuyez sur [ENTREE] pour continuer..."
    ;;

  q)
    tput reset
    clear
    source /etc/optimus/devtools/install.sh
    read -p "Appuyez sur [ENTREE] pour continuer..."
    ;;

  r)
    tput reset
    clear
    source /etc/optimus/backup/install.sh
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

  y)
    tput reset
    clear
    source /etc/optimus/upgrade/install.sh
  	source /etc/optimus/diskpart/install.sh
    source /etc/optimus/crypt/install.sh
    source /etc/optimus/secure/install.sh
    source /etc/optimus/letsencrypt_ovh/install.sh
    source /etc/optimus/nginx/install.sh
    source /etc/optimus/docker/install.sh
    source /etc/optimus/mariadb/install.sh
    source /etc/optimus/optimus_base/install.sh
    source /etc/optimus/backup/install.sh
    qrencode -t ansi "otpauth://totp/debian@$DOMAIN.fr?secret=${SECURE_GOOGLEAUTH_KEY}&issuer=optimus"
    read -p "Appuyez sur [ENTREE] après avoir enregistré votre code ..."
    ;;

  z)
  	tput reset
  	clear
    if [ -z $DOMAIN ]; then require DOMAIN string "Veuillez renseigner votre nom de domaine :"; fi
    if [ -z $OVH_APP_KEY ]; then require OVH_APP_KEY string "Merci de renseigner votre clé OVH APPLICATION KEY"; source /root/.optimus; fi
    if [ -z $OVH_SECRET_KEY ]; then require OVH_SECRET_KEY string "Merci de renseigner votre clé OVH SECRET KEY"; source /root/.optimus; fi
    if [ -z $OVH_CONSUMER_KEY ]; then require OVH_CONSUMER_KEY string "Merci de renseigner votre clé OVH CONSUMER KEY"; source /root/.optimus; fi
    if [ -z $ADMIN_FIRSTNAME ]; then require ADMIN_FIRSTNAME string "Merci d'indiquer le prénom du premier administrateur à créer :"; source /root/.optimus; fi
    if [ -z $ADMIN_LASTNAME ]; then require ADMIN_LASTNAME string "Merci d'indiquer le nom de famille du premier administrateur à créer :"; source /root/.optimus; fi
    if [ -z $ADMIN_EMAIL_PREFIX ]; then require ADMIN_EMAIL_PREFIX string "Merci d'indiquer le préfixe de l'adresse email du premier administrateur à créer. Exemple 'alice.dupont' pour créer 'alice.dupont@$DOMAIN :"; source /root/.optimus; fi
    if [ -z $ADMIN_PASSWORD ]; then require ADMIN_PASSWORD password "Merci d'indiquer le mot de passe du premier administrateur '$ADMIN_EMAIL_PREFIX'. Au moins 9 caractères, 1 chiffre, 1 majuscule et 1 caractère spécial :"; fi
    update_conf VERBOSE 2
    update_conf UUID auto
    update_conf AES_KEY auto
    update_conf API_SHA_KEY auto
    update_conf SECURE_ROOT_PASSWORD auto
    update_conf SECURE_DEBIAN_PASSWORD auto
    update_conf MARIADB_ROOT_PASSWORD auto
    update_conf MODULE_BACKUP "Y"
    update_conf MODULE_CRYPT "Y"
    update_conf MODULE_DECRYPT "Y"
    update_conf MODULE_DISKPART "Y"
    update_conf MODULE_LETSENCRYPT_OVH "Y"
    update_conf MODULE_CLEANDNS_OVH "Y"
    update_conf MODULE_MARIADB "Y"
    update_conf MODULE_MARIADB_REMOTE_ACCESS "Y"
    update_conf MODULE_NGINX "Y"
    update_conf MODULE_DOCKER "Y"
    update_conf MODULE_OPTIMUS_BASE "Y"
    update_conf MODULE_UPGRADE "Y"
    update_conf MODULE_SECURE_UPDATE "Y"
    update_conf MODULE_SECURE_ENABLEFW "Y"
    update_conf MODULE_SECURE_FAIL2BAN "N"
    update_conf MODULE_SECURE_CHANGEROOTPASS "Y"
    update_conf MODULE_SECURE_CHANGEDEBIANPASS "Y"
    update_conf MODULE_SECURE_SSH_REPLACEDEFAULTPORT "Y"
    update_conf MODULE_SECURE_SSH_PORTKNOCKING "N"
    update_conf MODULE_SECURE_SSH_PORTKNOCKING_SEQUENCE "1083,1080,1082,1075"
    update_conf MODULE_SECURE_SSH_DISABLEROOTACCESS "Y"
    update_conf MODULE_SECURE_SSH_2FA "Y"
    update_conf AUTODECRYPT "Y"
    source /root/.optimus
    source /etc/optimus/upgrade/install.sh
  	source /etc/optimus/diskpart/install.sh
    source /etc/optimus/crypt/install.sh
    source /etc/optimus/secure/install.sh
    source /etc/optimus/letsencrypt_ovh/install.sh
    source /etc/optimus/nginx/install.sh
    source /etc/optimus/docker/install.sh
    source /etc/optimus/mariadb/install.sh
    source /etc/optimus/optimus_base/install.sh
    read -p "Appuyez sur [ENTREE] pour continuer ..."
    clear
    qrencode -t ansi "otpauth://totp/debian@$DOMAIN?secret=${SECURE_GOOGLEAUTH_KEY}&issuer=optimus"
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
    echo "APPUYER SUR [ENTREE] POUR CONTINUER"
	read -p ""
    echo
    echo_green "Si l'installation s'est bien déroulée, vous pourrez vous connecter à https://optimus.$DOMAIN"
    echo_green "Le serveur à renseigner est : api.$DOMAIN"
    echo_green "Les identifiants de connexion sont : $ADMIN_EMAIL_PREFIX@$DOMAIN / $ADMIN_PASSWORD"
    echo "APPUYER SUR [ENTREE] POUR REDEMARRER"
    read -p ""
    reboot
    ;;

  '')
    clear
    more /etc/optimus/LICENSE
    ;;
esac
done
