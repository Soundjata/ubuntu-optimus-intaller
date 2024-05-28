Ce dépôt contient des scripts bash de notre conception permettant d'installer et configurer très rapidement votre propre serveur OPTIMUS. Ce serveur sécurisé sous Linux DEBIAN constitue la base de toutes les applications développées par notre association CYBERTRON. 

Il permet notamment de stocker et d'accéder à l'ensemble de vos données (fichiers, courriels, agendas, sauvegardes, bases de données) dans des formats ouverts. Le serveur OPTIMUS intègre également les API de communication qui lui permettent d'échanger avec d'autres applications (dont OPTIMUS AVOCATS).

Nos serveurs OPTIMUS n'intègrent que des logiciels libres et opensource garantissant une gratuité totale, une sécurité maximale et une transparence absolue.

Les scripts ont été conçus pour fonctionner sur une installation minimale Debian 12.

Pour lancer l'installation sur votre serveur, il suffit d'exécuter la commande suivante :

`wget https://git.cybertron.fr/optimus/optimus-installer/-/raw/main/install.sh; sudo bash install.sh --generate; sudo bash /etc/optimus/menu.sh`

Pour plus d'informations, veuillez consulter notre [WIKI](https://wiki.cybertron.fr)
