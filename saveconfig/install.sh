#!/bin/bash
source /etc/optimus/functions.sh
source /root/.optimus

while : ; do

clear
echo
echo_red "Après avoir finalisé l'installation, il est vivement recommandé de sauvegarder la configuration et les clés de chiffrement."
echo_red "Ne les conservez pas sur le serveur lui-même, dans vos mails ou dans le cloud."
echo_red "Conservez les de préférence sur une ou plusieurs clés USB déconnectées du réseau et en lieu sûr."
echo_red "Si vous perdez vos clés de chiffrement, vos données seront irrémédiablement perdues."
echo
echo_green "voici les informations à sauvegarder en priorité et à stocker en lieu sûr :"
echo_green "- mot de passe de l'utilisateur debian : $DEBIAN_PASSWORD"
echo_green "- clé globale du module d'authentification à deux facteurs : $TWO_FA_KEY"
echo_green "- identifiant UUID du serveur : $UUID"
echo_green "- clé publique du serveur : /root/public.pem"
echo_green "- clé privée du serveur : /root/private.pem "
echo_green "- clé de chiffrement du disque (chiffrée avec la clé du serveur) : https://decrypt.optimus-avocats.fr/${UUID}_keyfile"
echo
echo_magenta "Tous les autres paramètres d'installation sont sauvegardés dans le fichier /root/.optimus"
echo_magenta "Il est recommandé d'en faire une copie afin de pouvoir réinstaller le serveur en cas de panne grave."
echo
echo_magenta "Il est également recommandé de faire une sauvegarde de l'entête du disque crypté qui peut permettre une restauration en cas de défaillance grave."
echo_magenta "Cet en-tête est dans le fichier /root/headerbackup"
echo
echo "APPUYER SUR [1] POUR AFFICHER LA CLE PUBLIQUE"
echo "APPUYER SUR [2] POUR AFFICHER LA CLE PRIVEE"
echo "APPUYER SUR [3] POUR AFFICHER LE FICHIER DE CONFIGURATION"
echo 
echo "APPUYER SUR [ENTREE] POUR REVENIR AU MENU"

read -n 1 y
case "$y" in

  1)
    clear
    more -d /root/public.pem
    read -n 1 -s -r -p ""
    ;;

  2)
    clear
    more -d /root/private.pem
    read -n 1 -s -r -p ""
    ;;

  3)
    clear
    more -d /root/.optimus
    read -n 1 -s -r -p ""
    ;;

  '')
  break

esac
done