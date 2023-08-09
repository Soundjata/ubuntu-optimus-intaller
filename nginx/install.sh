#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DU SERVEUR WEB NGINX" "blue" 200 "nginx" 0

output $OUTPUT_MODE "Modification de l'uid de l'utilisateur et du groupe www-data" "magenta" 200 "nginx" 5
verbose usermod --uid 219 www-data
verbose groupmod --gid 219 www-data
  
output $OUTPUT_MODE "Ajout de l'utilisateur debian au groupe www-data" "magenta" 200 "nginx" 20
verbose usermod -a -G www-data debian

output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "nginx" 35
verbose apt-get -qq install nginx incron

#echo_magenta "Ouverture du port 80 sur le firewall"
#if [ $(which /sbin/ufw) ]; then verbose /sbin/ufw allow 80; fi

output $OUTPUT_MODE "Paramétrage des vhosts" "magenta" 200 "nginx" 50
verbose mkdir -p /srv/vhosts/servers
verbose mkdir -p /srv/vhosts/locations
echo "include /srv/vhosts/servers/*;" > /etc/nginx/sites-enabled/default
verbose chown -R www-data:www-data /srv/vhosts

output $OUTPUT_MODE "Paramétrage des logs" "magenta" 200 "nginx" 65
verbose mkdir -p /var/log/optimus
verbose chown -R www-data:www-data /var/log/optimus

output $OUTPUT_MODE "Mise en place d'une veille sur les dossiers /srv/vhosts/servers et /srv/vhosts/locations" "magenta" 200 "nginx" 80
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

output $OUTPUT_MODE "Redémarrage des services" "magenta" 200 "nginx" 95
verbose systemctl reload nginx
verbose systemctl restart incron

output $OUTPUT_MODE "Le serveur NGINX a été installé avec succès" "green" 200 "nginx" 100