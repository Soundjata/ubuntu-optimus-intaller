 #!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "INSTALLATION DE FAIL2BAN" "blue" 200 "fail2ban" 0

output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "fail2ban" 25
verbose apt-get -qq install fail2ban

output $OUTPUT_MODE "Installation des prisons locales" "magenta" 200 "fail2ban" 50
envsubst '${DOMAIN}' < /etc/optimus/fail2ban/jail.local > /etc/fail2ban/jail.local
#commit suggéré sur le github fail2ban mais pas encore implémenté
sed -i '/mdpr-ddos = lost connection after(?! DATA)/c\mdpr-ddos = (?:lost connection after(?! DATA) [A-Z]+|disconnect(?= from \S+(?: \S+=\d+)* auth=0/(?:[1-9]|\d\d+)))' /etc/fail2ban/filter.d/postfix.conf
sed -i "s/example.com/$DOMAIN/g" /etc/hosts

output $OUTPUT_MODE "Redémarrage des services" "magenta" 200 "fail2ban" 75
systemctl restart fail2ban

output $OUTPUT_MODE "FAIL2BAN a été installé avec succès !" "green" 200 "fail2ban" 100