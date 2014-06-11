#######################################################################
#                          InitWebProject.sh                          #
#######################################################################
# Author: Kabbaj Amine
# Date Creation: 2014-05-22
# Last modification: 2014-05-28

# DESCRIPTION
# Initialize what needed for my web projects in a new tmux
# window with different tmux panes for:
# - LAMMP (XAMMP).
# - Compass.
# - brolink.js.
#
# - Then move the current shell to the project directory.

# USAGE
# - If included to the path:
#		. InitWebProject.sh nameProject

# NOTES
# - Project name without spaces.
#######################################################################

#!/bin/bash
IFS='
'

#####################
# VARIABLES
#####################

project_name=${1}

# 1) Project folder.
root="/opt/lampp/htdocs/mesProjets/$project_name"

# 2) Localization of binaries.
lammp="/opt/lampp/xampp"
compass="/usr/local/bin/compass"
brolink="/usr/local/bin/brolink.js"

# Colors.
red="\033[31m"
white="\033[0m"
green="\033[32m"
yellow="\033[33m"


#####################
# FUNCTIONS
#####################

showTitle () {
	echo -e $green"\n~~~~~~~~~~ $1 ~~~~~~~~~~\n"$white
}
checkProjectName() {
	if [ -z $1 ]
	then
		echo -e $red"You should specify a project name"$white
		kill -SIGINT $$
	fi
}
checkBinaries() {
	if [ ! -x $1 ]
	then
		echo -e $1 $red"was not found"$white &&
		kill -SIGINT $$
	else
		echo -e $1 $yellow"was found"$white
	fi
}
createRootFolderIfNot () {
	if [ ! -d $1 ]
	then
		echo -e $yellow"The project name is"$white $project_name $green"(New project)\n"$white
		mkdir $1
	else
		echo -e $yellow"The project name is"$white $project_name $green"(Existent project)\n"$white
	fi
}
startLampp () {
	sudo $lammp start
}
executeCompass() {
	if [ -e "$1/config.rb" ]
	then
		tmux split-window "compass watch $1"
	else
		tmux split-window "compass create --css-dir css --output-style nested --no-line-comments --bar -q $1 && mkdir $1/css && touch $1/sass/app.scss && compass watch $1"
	fi
}
executeBrolink () {
	tmux split-window -h brolink.js
}


#####################
# CHECKING
#####################

showTitle "CHECKING"

# Verification of the root folder.
checkProjectName $project_name
createRootFolderIfNot $root

# Verification of the binaries.
for file in $lammp $compass $brolink;
do
	checkBinaries $file
done &&


#####################
# PROCESSING
#####################

showTitle "PROCESSING"

tmux rename-window $project_name

# Execution of the components.
startLampp &&
executeCompass $root &&
executeBrolink

# Move to the project folder.
tmux select-pane -t 1
cd $root

echo -e "\n"
return 0
