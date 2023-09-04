#!/bin/bash

# Get a list of directories containing a Dockerfile
dirs=()
while IFS= read -r -d '' dir; do
	dirs+=("${dir%*/}")
done < <(find . -type f -name "Dockerfile" -printf "%h\0" | sort -zu)

num_dirs=${#dirs[@]}

# Display the interactive menu
while true; 
do
	clear
	echo "What container do you want to build ?"
	for i in $(seq 0 $(($num_dirs - 1))); 
	do
		tput setaf 2  # Set the text color to green
		tput cup $(($i + 2)) 2
		echo "$(($i + 1)). ${dirs[$i]#./}"
		tput sgr0  # Reset the text color
	done
	tput cup $(($num_dirs + 3)) 0
	echo -n "Please select a directory (1-$num_dirs) : "

	# Activate non-canonical mode to read input character by character
	stty_orig=$(stty -g)
	stty -icanon -echo

	# Read input character by character until a digit is obtained
	selection=""
	while [[ ! "$selection" =~ ^[0-9]+$ ]]; 
	do
		read -s -n 1 char
		if [[ "$char" =~ ^[0-9]+$ ]];
		then
			selection=$char
			echo "$char"
		fi
	done

	# Restore canonical mode
	stty "$stty_orig"

	# Check if the selection is valid
	if [[ "$selection" -ge 1 && "$selection" -le $num_dirs ]]; 
	then
		selected_dir=${dirs[$(($selection - 1))]}
		selected_dir=${selected_dir#./}  # Remove "./" from the beginning of the variable
		source <(sudo cat /root/.optimus)
		DEV=$1
		if [ -n "$DEV" ] && [ $DEV == "dev" ]
		then
			docker stop $selected_dir-v5
			docker image rm --force git.cybertron.fr:5050/optimus/$selected_dir/v5:latest
			docker build -t git.cybertron.fr:5050/optimus/$selected_dir/v5:latest -f $selected_dir/Dockerfile .
			cd /srv/dev/$selected_dir
			docker-compose -f docker-compose.yml -f docker-compose-dev.yml down
			docker-compose -f docker-compose.yml -f docker-compose-dev.yml up
		else
			docker stop $selected_dir-v5
			docker image rm --force git.cybertron.fr:5050/optimus/$selected_dir/v5:latest
			docker build -t git.cybertron.fr:5050/optimus/$selected_dir/v5:latest -f $selected_dir/Dockerfile .
			cd /srv/dev/$selected_dir
			docker-compose down
			docker-compose up
		fi
		break
	else
		echo "Invalid choice. Press any key to continue."
		read -n 1
	fi
done