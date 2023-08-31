source /etc/optimus/functions.sh

mkdir /root/tmpramfs
mount ramfs /root/tmpramfs/ -t ramfs
wget -O '/root/tmpramfs/'$UUID'_keyfile' 'https://decrypt.optimus-avocats.fr/'$UUID'_keyfile'
cp /root/private.pem /root/tmpramfs/private.pem
cp /root/public.pem /root/tmpramfs/public.pem
cp /root/decrypt.sh /root/tmpramfs/decrypt.sh
cp /root/.optimus /root/tmpramfs/passwords.txt
zip -jj -P "$DOMAIN" /root/tmpramfs/secret.zip /root/tmpramfs/*

OUTPUT='{'
OUTPUT=$OUTPUT'"operation":"get_config", '
OUTPUT=$OUTPUT'"progress":"100", '
OUTPUT=$OUTPUT'"domain":"'$DOMAIN'", '
OUTPUT=$OUTPUT'"ip":"'$( wget -qO- ipinfo.io/ip )'", '
OUTPUT=$OUTPUT'"uuid":"'$UUID'", '
OUTPUT=$OUTPUT'"ssh_port":"'$( cat /etc/ssh/sshd_config | grep "Port " | tr -dc '0-9' )'", '
OUTPUT=$OUTPUT'"debian_password":"'$DEBIAN_PASSWORD'", '
if [ ! -z $TWO_FA_KEY ]; then OUTPUT=$OUTPUT'"two_fa_key":"'$TWO_FA_KEY'", '; fi
if [ ! -z $PORTKNOCKING_SEQUENCE ]; then OUTPUT=$OUTPUT'"port_knocking_sequence":"'$PORTKNOCKING_SEQUENCE'", '; fi
OUTPUT=$OUTPUT'"zip":"'$( base64 -w 0 /root/tmpramfs/secret.zip )'", '
OUTPUT=$OUTPUT'"hostname":"'$HOSTNAME'"}'

umount /root/tmpramfs
rmdir /root/tmpramfs

echo $OUTPUT