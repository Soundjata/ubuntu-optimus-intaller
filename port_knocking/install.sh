 #!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "PROTECTION DU SERVEUR SSH AVEC UNE SEQUENCE DE PORT KNOCKING" "blue" 200 "port_knocking" 0

output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "port_knocking" 25
verbose apt-get -qq install knockd

output $OUTPUT_MODE "Modification des fichiers de configuration" "magenta" 200 "port_knocking" 50
verbose cp /etc/optimus/port_knocking/knockd.conf /etc/knockd.conf
if grep -q "Port 7822" /etc/ssh/sshd_config
then
	verbose sed -i 's/22/7822/g' /etc/knockd.conf
fi
verbose sed -i 's/START_KNOCKD=0/START_KNOCKD=1/g' /etc/default/knockd
#Modification nécessaire pour rendre knockd compatible avec UFW mais qui devrait être intégrée nativement dans la prochaine version de knockd
#verbose sed -i 's/ProtectSystem=full/ProtectSystem=true/g' /lib/systemd/system/knockd.service

output $OUTPUT_MODE "Redémarrage des services" "magenta" 200 "port_knocking" 75
if ! grep -q "\[Install\]" /lib/systemd/system/knockd.service
then
	echo -e "\n[Install]\nWantedBy=multi-user.target\n" >> /lib/systemd/system/knockd.service
fi
verbose systemctl daemon-reload
verbose systemctl restart knockd
verbose systemctl --quiet enable knockd.service

output $OUTPUT_MODE "Le serveur SSH a bien été sécurisé avec une sequence de port knocking !" "green" 200 "port_knocking" 100