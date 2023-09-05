#!/bin/bash
cd /srv/optimus

# LISTE LES DOSSIERS QUI CONTIENNENT UN FICHIER DOCKERFILE
dirs=()
while IFS= read -r -d '' dir; do
	dirs+=("${dir%*/}")
done < <(find . -type f -name "Dockerfile" -printf "%h\0" | sort -zu)

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