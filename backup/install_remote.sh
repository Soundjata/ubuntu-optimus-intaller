#Installation des paquets requis
apt-get install -qq -y rdiff-backup rdiff-backup-fs

#Règlage de l'heure
sudo timedatectl set-timezone Europe/Paris

#Création de l'utilisateur autobackup
[ $(getent group autobackup) ] || groupadd autobackup --gid 204
[ $(getent passwd autobackup) ] || useradd -g autobackup --uid 204 autobackup

#Communication de la clé publique à l'utilisateur autobackup
mkdir -p /home/autobackup/.ssh
cp /home/debian/.ssh/authorized_keys /home/autobackup/.ssh/authorized_keys
chown autobackup:autobackup /home/autobackup/.ssh/authorized_keys
chmod 600 /home/autobackup/.ssh/authorized_keys

#Ajout de l'utilisateur autobackup dans les sudoers
if ! grep -q "autobackup ALL=(ALL) NOPASSWD: ALL" /etc/sudoers
then
  echo 'autobackup ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
fi

#Création des dossiers
mkdir -p /srv
chown autobackup:autobackup /srv

mkdir -p /backup
chown autobackup:autobackup /backup

#Création de l'utilisateur/groupe mailboxes pour reproduire la configuration du serveur principal
[ $(getent group mailboxes) ] || sudo groupadd mailboxes --gid 203
[ $(getent passwd mailboxes) ] || sudo useradd -g mailboxes -s /bin/false -d /srv/mailboxes --uid 203 mailboxes
