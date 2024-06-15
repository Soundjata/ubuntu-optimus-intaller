#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DU SERVEUR WEB NGINX" "blue" 200 "nginx" 0

output $OUTPUT_MODE "Modification de l'uid de l'utilisateur et du groupe www-data" "magenta" 200 "nginx" 5
verbose usermod --uid 219 www-data 2> /dev/null
verbose groupmod --gid 219 www-data 2> /dev/null
  
output $OUTPUT_MODE "Ajout de l'utilisateur ubuntu au groupe www-data" "magenta" 200 "nginx" 20
verbose usermod -a -G www-data ubuntu

output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "nginx" 35
verbose apt-get -qq --yes install nginx libnginx-mod-mail libnginx-mod-stream incron

output $OUTPUT_MODE "Paramétrage des vhosts" "magenta" 200 "nginx" 50
verbose mkdir -p /srv/vhosts/servers
verbose mkdir -p /srv/vhosts/locations
verbose mkdir -p /srv/vhosts/mail
verbose mkdir -p /srv/vhosts/streams

if ! grep -q "include /srv/vhosts/servers/*" /etc/nginx/sites-enabled/default
then
	printf "include /srv/vhosts/servers/*;\n" > /etc/nginx/sites-enabled/default
fi

if ! grep -q "include /srv/vhosts/mail/*" /etc/nginx/nginx.conf
then
	printf "include /srv/vhosts/mail/*;\n\n" >> /etc/nginx/nginx.conf
fi

if ! grep -q "include /srv/vhosts/streams/*" /etc/nginx/nginx.conf
then
	printf "stream\n{\ninclude /srv/vhosts/streams/*;\n}" >> /etc/nginx/nginx.conf
fi

verbose chown -R www-data:www-data /srv/vhosts
verbose rm /usr/share/nginx/html/index.html
verbose touch /usr/share/nginx/html/index.html

output $OUTPUT_MODE "Paramétrage des logs" "magenta" 200 "nginx" 65
verbose mkdir -p /var/log/optimus
verbose chown -R www-data:www-data /var/log/optimus

output $OUTPUT_MODE "Mise en place d'une veille sur /srv/vhosts/" "magenta" 200 "nginx" 80
if ! grep -q "root" /etc/incron.allow
then
  echo "root" >> /etc/incron.allow
fi
verbose touch /var/spool/incron/root
if ! grep -q "/srv/vhosts" /var/spool/incron/root
then
  echo "/srv/vhosts/mail IN_CREATE,IN_DELETE,IN_MOVE,IN_CLOSE_WRITE /usr/bin/systemctl reload nginx" >> /var/spool/incron/root
  echo "/srv/vhosts/streams IN_CREATE,IN_DELETE,IN_MOVE,IN_CLOSE_WRITE /usr/bin/systemctl reload nginx" >> /var/spool/incron/root
  echo "/srv/vhosts/servers IN_CREATE,IN_DELETE,IN_MOVE,IN_CLOSE_WRITE /usr/bin/systemctl reload nginx" >> /var/spool/incron/root
  echo "/srv/vhosts/locations IN_CREATE,IN_DELETE,IN_MOVE,IN_CLOSE_WRITE /usr/bin/systemctl reload nginx" >> /var/spool/incron/root
fi

output $OUTPUT_MODE "Redémarrage des services" "magenta" 200 "nginx" 95
verbose systemctl reload nginx
verbose systemctl restart incron

output $OUTPUT_MODE "Le serveur NGINX a été installé avec succès" "green" 200 "nginx" 100