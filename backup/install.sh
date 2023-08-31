#!/bin/bash
source /etc/optimus/functions.sh
if [ -z $DOMAIN ]; then require DOMAIN string "Veuillez renseigner votre nom de domaine :"; source /root/.optimus; fi
if [ -z $MODULE_BACKUP ]; then require MODULE_BACKUP yesno "Voulez-vous installer le module de sauvegarde ?"; source /root/.optimus; fi
if [ -z $MARIADB_ADMIN_PASSWORD ] || [ $MARIADB_ADMIN_PASSWORD = "auto" ]; then require MARIADB_ADMIN_PASSWORD password "Veuillez renseigner le mot de passe de l'administrateur MARIADB :"; source /root/.optimus; fi
if [[ $MODULE_BACKUP =~ ^[YyOo]$ ]] && [ -z $BACKUP_SERVER ]; then require BACKUP_SERVER string "Veuillez renseigner l'adresse IP du serveur de sauvegarde"; source /root/.optimus; fi
if [[ $MODULE_BACKUP =~ ^[YyOo]$ ]] && [ -z $BACKUP_SERVER_SSHPORT ]; then require BACKUP_SERVER_SSHPORT string "Veuillez renseigner le port SSH du serveur de sauvegarde"; source /root/.optimus; fi
source /root/.optimus

if [ $MODULE_BACKUP = "Y" ]
then
  echo
  echo_green "==== SAUVEGARDE AUTOMATIQUE ===="

  echo_magenta "Installation des paquets requis"
  verbose apt-get -qq --yes install rdiff-backup mailutils sshfs


  echo_magenta "Envoi de la clé publique au serveur distant"
  if [ ! -f /root/private.pem ]
  then
    openssl genrsa -out /root/private.pem 4096 &> /dev/null
    openssl rsa -in /root/private.pem -outform PEM -pubout -out /root/public.pem &> /dev/null
  fi
  verbose ssh-keygen -f /root/.ssh/known_hosts -R $BACKUP_SERVER
  verbose ssh-keygen -y -f /root/private.pem | ssh debian@$BACKUP_SERVER -o "StrictHostKeyChecking no" -p $BACKUP_SERVER_SSHPORT "mkdir -p ~/.ssh && cat >> /home/debian/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

  echo_magenta "Communication de la clé publique à l'utilisateur debian"
  cp /root/private.pem /home/debian/private.pem
  cp /root/public.pem /home/debian/public.pem
  chown debian:debian /home/debian/private.pem
  chown debian:debian /home/debian/public.pem

  echo_magenta "Configuration du serveur distant"
  scp -P $BACKUP_SERVER_SSHPORT -i /root/private.pem /etc/optimus/backup/install_remote.sh debian@$BACKUP_SERVER:/home/debian/install_remote.sh
  ssh -i /root/private.pem -p $BACKUP_SERVER_SSHPORT debian@$BACKUP_SERVER sudo chmod 700 /home/debian/install_remote.sh
  ssh -i /root/private.pem -p $BACKUP_SERVER_SSHPORT debian@$BACKUP_SERVER sudo /home/debian/install_remote.sh


  echo_magenta "Création des dossiers sur le serveur local"
  verbose mkdir -p /srv/db-backup
  if [ -d /srv/files ]
  then
    verbose mkdir -p /srv/files/backup@$DOMAIN
    sshfs autobackup@$BACKUP_SERVER:/backup /srv/files/backup@$DOMAIN -o IdentityFile=/root/private.pem -o sftp_server="/usr/bin/sudo /usr/lib/openssh/sftp-server" -o allow_other -p $BACKUP_SERVER_SSHPORT
    verbose mariadb -u root -e "INSERT IGNORE INTO server.users VALUES ('2', '1', 'backup@$DOMAIN', AES_ENCRYPT('$MARIADB_ADMIN_PASSWORD','$AES_KEY'), '$(date +"%F %T")', null, null, null);"
    verbose mariadb -u root -e "INSERT IGNORE INTO cloud.groupmembers VALUES ('1', '2', '1');"
  fi


  echo_magenta "Installation du script de sauvegarde"
  envsubst '${DOMAIN} ${BACKUP_SERVER} ${BACKUP_SERVER_SSHPORT}' < /etc/optimus/backup/optimus-backup.sh > /srv/optimus-backup.sh
  chmod 700 /srv/optimus-backup.sh


  echo_magenta "Création de la tâche automatique quotidienne"
  cp /etc/optimus/backup/optimus-backup.timer /etc/systemd/system/optimus-backup.timer
  cp /etc/optimus/backup/optimus-backup.service /etc/systemd/system/optimus-backup.service
  systemctl enable optimus-backup.timer
  systemctl start optimus-backup.timer
  systemctl daemon-reload
fi
