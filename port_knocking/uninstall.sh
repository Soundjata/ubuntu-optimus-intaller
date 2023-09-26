 #!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "DESACTIVATION DE LA SEQUENCE DE PORT KNOCKING" "blue" 200 "port_knocking_uninstall" 0

verbose systemctl daemon-reload
verbose systemctl stop knockd
verbose systemctl --quiet disable knockd.service
verbose apt-get -qq --yes remove knockd
verbose sed -i 's/START_KNOCKD=1/START_KNOCKD=0/g' /etc/default/knockd

if grep -q "Port 7822" /etc/ssh/sshd_config
then
	output $OUTPUT_MODE "Réouverture du port SSH 7822" "magenta" 200 "port_knocking" 80
	verbose /sbin/ufw allow 7822
else
	output $OUTPUT_MODE "Réouverture du port SSH 22" "magenta" 200 "port_knocking" 80
	verbose /sbin/ufw allow 22
fi

output $OUTPUT_MODE "La séquence de port knocking a bien été désactivée" "green" 200 "port_knocking_uninstall" 100
