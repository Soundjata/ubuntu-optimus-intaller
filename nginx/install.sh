#!/bin/bash
source /etc/optimus/functions.sh
if [ -z $MODULE_NGINX ]; then require MODULE_NGINX yesno "Souhaitez vous installer le serveur web NGINX ?"; source /root/.optimus; fi
source /root/.optimus

if [ $MODULE_NGINX = "Y" ]
then
  echo
  echo_green "==== INSTALLATION DU SERVEUR WEB NGINX ===="

  echo_magenta "Modification de l'uid de l'utilisateur et du groupe www-data"
  verbose usermod --uid 219 www-data
  verbose groupmod --gid 219 www-data
  
  echo_magenta "Ajout de l'utilisateur debian au groupe www-data"
  verbose usermod -a -G www-data debian

  echo_magenta "Installation des paquets"
  verbose apt-get -qq install nginx incron

  echo_magenta "Ouverture du port 80 sur le firewall"
  if [ $(which /sbin/ufw) ]; then verbose /sbin/ufw allow 80; fi

  echo_magenta "Paramétrage des vhosts"
  verbose mkdir -p /srv/vhosts/servers
  verbose mkdir -p /srv/vhosts/locations
  echo "include /srv/vhosts/servers/*;" > /etc/nginx/sites-enabled/default
  verbose chown -R www-data:www-data /srv/vhosts

  echo_magenta "Paramétrage des logs"
  verbose mkdir -p /var/log/optimus
  verbose chown -R www-data:www-data /var/log/optimus

  echo_magenta "Mise en place d'une veille sur les dossiers /srv/vhosts/servers et /srv/vhosts/locations"
  if ! grep -q "root" /etc/incron.allow
  then
    echo "root" >> /etc/incron.allow
  fi
  verbose touch /var/spool/incron/root
  if ! grep -q "/srv/vhosts" /var/spool/incron/root
  then
    echo "/srv/vhosts/servers IN_CREATE,IN_DELETE,IN_MOVE,IN_CLOSE_WRITE /usr/bin/systemctl reload nginx" >> /var/spool/incron/root
    echo "/srv/vhosts/locations IN_CREATE,IN_DELETE,IN_MOVE,IN_CLOSE_WRITE /usr/bin/systemctl reload nginx" >> /var/spool/incron/root
  fi

  echo_magenta "Redémarrage des services"
  verbose systemctl reload nginx
  verbose systemctl restart incron
fi