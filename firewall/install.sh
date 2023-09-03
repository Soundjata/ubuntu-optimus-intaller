#!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DU PARE FEU" "blue" 200 "firewall" 0

output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "firewall" 5
verbose apt -qq install ufw 2> /dev/null

if grep -q "Port 7822" /etc/ssh/sshd_config
then
	output $OUTPUT_MODE "Ouverture du port 7822 (SSH)" "magenta" 200 "firewall" 15
	verbose /sbin/ufw allow 7822
else
	output $OUTPUT_MODE "Ouverture du port 22 (SSH)" "magenta" 200 "firewall" 15
	verbose /sbin/ufw allow 22
fi

output $OUTPUT_MODE "Ouverture du port 80 (HTTP)" "magenta" 200 "firewall" 25
verbose /sbin/ufw allow 80

output $OUTPUT_MODE "Ouverture du port 443 (HTTPS)" "magenta" 200 "firewall" 35
verbose /sbin/ufw allow 443

output $OUTPUT_MODE "Ouverture du port 25 (SMTP)" "magenta" 200 "firewall" 45
verbose /sbin/ufw allow 25

output $OUTPUT_MODE "Ouverture du port 143 (IMAP)" "magenta" 200 "firewall" 55
verbose /sbin/ufw allow 143

output $OUTPUT_MODE "Ouverture du port 465 (SMTPS)" "magenta" 200 "firewall" 65
verbose /sbin/ufw allow 465

output $OUTPUT_MODE "Ouverture du port 587 (SMTPS)" "magenta" 200 "firewall" 75
verbose /sbin/ufw allow 587

output $OUTPUT_MODE "Ouverture du port 993 (IMAPS)" "magenta" 200 "firewall" 85
verbose /sbin/ufw allow 993

output $OUTPUT_MODE "Activation du pare feu" "magenta" 200 "firewall" 95
verbose /sbin/ufw --force enable

output $OUTPUT_MODE "Le pare feu a été installé avec succès" "green" 200 "firewall" 100