 #!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "PROTECTION DU SERVEUR SSH AVEC UNE SEQUENCE DE PORT KNOCKING" "blue" 200 "port_knocking" 0

if [ ! -f /etc/ufw/applications.d/ufw-webserver ]
then
	output $OUTPUT_MODE "Installation impossible : le Pare feu doit être installé préalablement" "red" 400 "port_knocking" 100
	exit
fi

if [ -z $PORTKNOCKING_SEQUENCE ]
then 
	PORTKNOCKING_SEQUENCE="1083,1080,1082,1075"
	update_conf PORTKNOCKING_SEQUENCE $PORTKNOCKING_SEQUENCE
fi

output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "port_knocking" 20
verbose apt-get -qq install knockd

output $OUTPUT_MODE "Modification des fichiers de configuration" "magenta" 200 "port_knocking" 40
envsubst '${PORTKNOCKING_SEQUENCE}' < /etc/optimus/port_knocking/knockd.conf > /etc/knockd.conf
if grep -q "Port 7822" /etc/ssh/sshd_config
then
	verbose sed -i 's/22/7822/g' /etc/knockd.conf
fi
verbose sed -i 's/START_KNOCKD=0/START_KNOCKD=1/g' /etc/default/knockd
NETWORK_INTERFACE=$(ip route get 8.8.8.8 | awk -- '{printf $5}')
verbose sed -i 's/#KNOCKD_OPTS="-i eth1"/KNOCKD_OPTS="-i '$NETWORK_INTERFACE'"/g' /etc/default/knockd

output $OUTPUT_MODE "Redémarrage des services" "magenta" 200 "port_knocking" 60
if ! grep -q "\[Install\]" /lib/systemd/system/knockd.service
then
	echo -e "\n[Install]\nWantedBy=multi-user.target\n" >> /lib/systemd/system/knockd.service
fi
verbose systemctl daemon-reload
verbose systemctl restart knockd
verbose systemctl --quiet enable knockd.service

if grep -q "Port 7822" /etc/ssh/sshd_config
then
	output $OUTPUT_MODE "Fermeture du port SSH 7822" "magenta" 200 "port_knocking" 80
	verbose /sbin/ufw deny 7822
else
	output $OUTPUT_MODE "Fermeture du port SSH 22" "magenta" 200 "port_knocking" 80
	verbose /sbin/ufw deny 22
fi

output $OUTPUT_MODE "La séquence de port knocking suivante a bien été configurée : $PORTKNOCKING_SEQUENCE" "green" 200 "port_knocking" 100
