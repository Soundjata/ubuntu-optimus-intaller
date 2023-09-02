 #!/bin/bash
source /etc/optimus/functions.sh

output $OUTPUT_MODE
output $OUTPUT_MODE "DESACTIVATION DU CODE A DEUX FACTEURS SUR LE SERVEUR SSH" "blue" 200 "2fa_uninstall" 0

output $OUTPUT_MODE "Modification du fichier /etc/ssh/sshd_config" "blue" 200 "2fa_uninstall" 25
verbose sed -i 's/KbdInteractiveAuthentication yes/KbdInteractiveAuthentication no/g' /etc/ssh/sshd_config

output $OUTPUT_MODE "Modification du fichier /etc/pam.d/sshd" "blue" 200 "2fa_uninstall" 50
verbose sed -i '/auth required pam_google_authenticator.so/d' /etc/pam.d/sshd

output $OUTPUT_MODE "Redémarrage des services" "magenta" 200 "2fa_uninstall" 75
verbose systemctl restart sshd

output $OUTPUT_MODE "Le serveur SSH n'est plus sécurisé avec un code 2FA" "green" 200 "2fa" 100