#!/bin/bash
if [ -z $1 ] 		# Verification de l'existance du 1er parametre
then
	echo "Veuillez mettre un fichier dictionaire en paramètre"
	exit 2
elif [ ! -e $1 ]	# Verification si le fichier existe
then
	echo "Le fichier n'existe pas"
	exit 2
elif [[ ! -f $1 ]]
then
	echo "$1 n'est pas un fichier"
	exit 2
elif [ ! -r $1 ]	# Verification si le fichier est lisible
then
	echo "Le fichier n'est pas lisible"
	exit 2
elif [[ "$2" == "-specific" ]]	# Recherche specifique
then
	number=$(grep -c -i $3 $1)	# Compte le nombre de mots contenant le caractere dans le fichier (-i pour insensible à la case et -c pour count)
	echo "${number} - $3"
elif [[ "$2" == "-jouer" ]]	# Recherche de jouer
then 
	echo "C'est partie!!!"	
	let "score= 0"
	# On vide le fichier resultat.txt (ou on le crée s'il n'existe pas déjà)
	echo '' > resultat.txt
	echo "Combien de mots pour jouer?"
	read -p 'Entrez un nombre (99 maximum) : ' -n 2 nb_mots
	## On sort vérifie si un nombre a bien été entré
	if ! [[ "$nb_mots" =~ ^[0-9]+$ ]]
    then
		echo ''
        echo "Sorry integers only"
		exit 2
	fi
	## On prend nb_mots mots aléatoirement que l'on place dans resultat.txt
	sort -R $1 | head -n $nb_mots > resultat.txt
	echo "Le jeu commence, la cloche tourne..."
	starttime=$(date +%s)
	for i in `seq 1 $nb_mots`;
	do
		## head -n $i resultat.txt permet de choisir les i première lignes (la derniere ligne sera donc la i)
		## tail -1 affiche la premiere ligne en partant du bas
		## tr -d " \t\n\r" pour supprimer les espaces, les sauts de ligne, les retours à la ligne
		mot=$(head -n $i resultat.txt | tail -1 | tr -d " \t\n\r") 
		echo 'Quel est ce mot?'
		# grep -o . permet d'aficher ligne par ligne le mote
		# shuf permet de realiser un shuffle (melange) du tableau ainsi cree
		# tr -d "n" pour supprimer tous les sauts de lignes
		melange=$(echo $mot | grep -o . | shuf | tr -d " \t\n\r")
		echo ${melange}
		echo  ''
		## On donne 30 secondes au joueur pour repondre
		#####Ne marche pas tout le temps parfois je n'ai pas toute les lettres !!!
		read -p 'Votre reponse (vous avez 30 secondes) : ' -t 30 reponse 
		reponse=$(echo $reponse | tr 'a-z' 'A-Z' | tr -d " \t\n\r")
		## On verifie si la reponse en majuscule correspond
		if [ "$reponse" = "$mot" ]
		then
			echo 'Bien joue!'
			let "score=score+1"
		fi
	done
	endtime=$(date +%s)
	let "minutes=($starttime - $endtime)/60"
	let "secondes=($starttime - $endtime)%60"
	# On supprime le fichier de travail resultat.txt
	rm resultat.txt
	echo "Score final de " ${score} " sur " ${nb_mots} " realise en " ${minutes} "minutes et " ${secondes} "secondes"
	exit 1
else
	# On vide le fichier resultat.txt (ou on le crée s'il n'existe pas déjà)
	echo '' > resultat.txt
	if [[ "$#" == "-ascii" ]];
	then
	# On verifie si le fichier est encodé en ASCII
		if [[ $(file dico.txt | grep -i ascii | wc -l) == 0 ]];
		then 
		echo "Le fichier contient des caractéres Non-ASCII"
		exit 2
		fi
		# character-set encoding.
		echo "Resultat de l'analyse de : $(file -i $1)"
		echo "Utilisation de la table ASCII" 
		lg=`seq 65 90`
		for i in $lg;	# boucle de A = 65 a Z = 90 (ASCII)
		do
			# Convertion hexadecimal en caractere
			lettre=$(printf \\$(printf '%03o' $i))
			# On compte le nombre de fois que chaque lettre est utilisée au moins une fois dans un mot
			number=$(grep -c -i $lettre $1)
			# On met le résultat dans le fichier resultat.txt
			echo ${number} " - " ${lettre} >> resultat.txt	
		done
		else
		echo "Resultat de l'analyse de : $1" 
		# On parcours l'alphabet
		for lettre in {A..Z}
		do
			# On compte le nombre de fois que chaque lettre est utilisée au moins une fois dans un mot
			number=$(grep -i ${lettre} $1 | wc -l)
			# On met le résultat dans le fichier resultat.txt
			echo ${number} " - " ${lettre} >> resultat.txt
		done
	fi
	# Tri par ordre decroissant et affichage a l'ecran
	sort -n -r resultat.txt
	# On supprime le fichier de travail resultat.txt
	rm resultat.txt
fi
## utilisation ##
### cas 1 : bash langstat.sh dico.txt 
### cas 2 : bash langstat.sh dico.txt -ascii ==> Recherche en exploitant la table ASCII
### cas 3 : bash langstat.sh dico.txt -specific ==> Recheche d'une lettre ou groupe de lettre
### cas 4 : bash langstat.sh dico.txt -jouer 
##		==> Demander à  l'utilisateur un nombre de mots
## 		==> Prend ce nombre de mot au hasard dans le fichier dico.txt (paramètre 1) et les met dans resultat.txt
##		==> Chaque est alors presente sous forme melanger. L'utilisateur dispose de 30s/ mots
##		==> Supprime resultat.txt et affiche le score obtenu avec quel temps
