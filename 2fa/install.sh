 #!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "SECURISATION DE L'ACCES SSH AVEC UN CODE A DEUX FACTEURS" "blue" 200 "2fa" 0

output $OUTPUT_MODE "Installation des paquets requis" "magenta" 200 "2fa" 15
verbose apt-get -qq --yes install libpam-google-authenticator ntp

output $OUTPUT_MODE "Activation de l'authentification à deux facteurs" "magenta" 200 "2fa" 30
if ! grep -q "auth required pam_google_authenticator.so" /etc/pam.d/sshd
then
	echo 'auth required pam_google_authenticator.so' >> /etc/pam.d/sshd
fi
verbose sed -i 's/KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/g' /etc/ssh/sshd_config

if [ ! -f /root/.google_authenticator ]
then
	output $OUTPUT_MODE "Génération des clés d'accès" "magenta" 200 "2fa" 45
	google-authenticator --time-based --force --quiet --disallow-reuse --window-size=3 --rate-limit=3 --rate-time=30 --emergency-codes=4 --label=$ID@$DOMAIN --issuer=OPTIMUS
	update_conf TWO_FA_KEY $(cat /root/.google_authenticator | head -1)

	output $OUTPUT_MODE "Installation des clés d'accès" "magenta" 200 "2fa" 60
	source /etc/os-release
	if [ -d "/home/$ID" ]
	then
		verbose cp /root/.google_authenticator /home/$ID/.google_authenticator
	verbose chown $ID:$ID /home/$ID/.google_authenticator
	fi
fi

output $OUTPUT_MODE "Redémarrage des services" "magenta" 200 "2fa" 75
verbose systemctl restart sshd

output $OUTPUT_MODE "Le serveur SSH a été sécurisé avec un code 2FA" "green" 200 "2fa" 100