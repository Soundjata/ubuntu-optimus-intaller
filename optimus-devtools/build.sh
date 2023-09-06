#!/bin/bash
cd /srv/optimus

# LISTE LES DOSSIERS QUI CONTIENNENT UN FICHIER DOCKERFILE
mapfile -t dirs < <( find "/srv/services" -type f -name "*.json")
for ((i=0; i<${#dirs[@]}; i++))
do
  dirs[$i]=$(echo "${dirs[$i]}" | sed "s/\/srv\/services\///g")
  dirs[$i]=$(echo "${dirs[$i]}" | sed "s/.json//g")
done

num_dirs=${#dirs[@]}

# AFFICHAGE DU MENU INTERACTIF
while true; 
do
	clear
	echo "Quel conteneur voulez-vous reconstruire ?"
	for i in $(seq 0 $(($num_dirs - 1))); 
	do
		tput setaf 2  # COULEUR DU TEXTE VERTE
		tput cup $(($i + 2)) 2
		echo "$(($i + 1)). ${dirs[$i]#./}"
		tput sgr0  # COULEUR DU TEXTE PAR DEFAUT
	done

    tput setaf 1
    tput cup $(($num_dirs + 3)) 0
    echo "  X. Quitter"
    tput sgr0
	
    tput cup $(($num_dirs + 5)) 0
	echo -n "Merci de sélectionner un dossier (1-$num_dirs) : "

	# ACTIVATION DU MODE CANONICAL POUR LIRE LES CARACTERES TAPPES
	stty_orig=$(stty -g)
	stty -icanon -echo

	# LECTURE DES CARACTERES ENTRES JUSQU'A OBTENTION D'UN CHIFFRE
	selection=""
	while [[ ! "$selection" =~ ^[0-9]+$ ]]; 
	do
		read -s -n 1 char
		if [[ "$char" =~ ^[0-9]+$ ]];
		then
			selection=$char
			echo "$char"
		fi

        if [[ "$char" =~ ^[Xx]$ ]]
        then
            source /etc/optimus/menu.sh
        fi
	done

	# RESTAURATION DU MODE CANONIQUE
	stty "$stty_orig"

	# VERIFICATION DE LA VALIDITE DE LA SELECTION
	if [[ "$selection" -ge 1 && "$selection" -le $num_dirs ]]; 
	then
		selected_dir=${dirs[$(($selection - 1))]}
		selected_dir=${selected_dir#./}  # SUPPRIME "./" AU DEBUT DE LA VARIABLE
		
		if [ ! -d "/srv/optimus/$selected_dir/.git" ]
		then
			rm -Rf "/srv/optimus/$selected_dir"
			mkdir -p "/srv/optimus/$selected_dir"
			chown debian:debian "/srv/optimus/$selected_dir"
			su -c "git clone git@git.cybertron.fr:optimus/$selected_dir /srv/optimus/$selected_dir" debian
		fi
		if [ ! -d "/srv/optimus/optimus-libs/.git" ]
		then
			rm -Rf "/srv/optimus/optimus-libs"
			mkdir -p "/srv/optimus/optimus-libs"
			chown debian:debian "/srv/optimus/optimus-libs"
			su -c "git clone git@git.cybertron.fr:optimus/optimus-libs /srv/optimus/optimus-libs" debian
		fi
		if [ ! -d "/srv/optimus/.vscode" ]
		then
			mkdir -p "/srv/optimus/.vscode"
			wget -O "/srv/optimus/.vscode/settings.json" "https://git.cybertron.fr/optimus/optimus-libs/-/raw/v5-dev/.vscode/settings.json"
		fi
		chown -R www-data:www-data /srv/optimus
		chmod +775 -R /srv/optimus

		docker build -t git.cybertron.fr:5050/optimus/$selected_dir/v5:dev -f $selected_dir/Dockerfile .
		DEV=1
		NAME=$selected_dir
		source <(sudo cat /etc/optimus/optimus-init/container_installer.sh)
		read -p "Appuyez sur [ENTREE] pour continuer..."
	else
		echo "Choix invalide. Pressez une touche pour continuer"
		read -n 1
	fi
done