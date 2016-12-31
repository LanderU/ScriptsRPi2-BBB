#!/bin/bash

: '

 maintainer Lander Usategui San Juan, e-mail: lander.usategui@gmail.com

'

#####################
####    COLORS   ####
#####################

redColor(){
	tput setaf 1
} # End red color

resetColor(){
	tput sgr 0
} # End Reset color

####################
######  USER  ######
####################

currentUser=`whoami`

clear

if [ $currentUser == "root" ]; then
	# CONSTANTS
	IMAGE_PATH="/Users/lander/ImagesFlash" #Change for your path
	DEVICE="/dev/disk2" #Change for your device
	FLASH_DEVICE="/dev/rdisk2" #Change for your device

	# Necessary variables
	cont=1
	indexArray=0
	imageArray=( )

	# Set vector with images
	for i in `ls $IMAGE_PATH`; do
		echo $cont"- "$i
		imageArray[$indexArray]=$i
		indexArray=$(($indexArray+1))
		cont=$(($cont+1))
	done

	# Read selection
	read -p "Choose the image: " flash

	if [ $flash -gt ${#imageArray[@]} ] || [ $flash -lt 0 ]; then
		clear
		redColor
		echo "Invalid number, launch the script again and choose one number of the list"
		resetColor

	else
		clear
		flash=$(($flash-1))
		# Check file extension 
		EXTENSION=`echo $$IMAGE_PATH/${imageArray[$flash]} | cut -d "." -f3`
		if [ -z $EXTENSION ]; then
			EXTENSION=`echo $$IMAGE_PATH/${imageArray[$flash]} | cut -d "." -f2`
			case $EXTENSION in
				"img" ) if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
							echo "Unmounted correctly"
							echo "Flashing, please wait..."
							SIZE=`du -h $IMAGE_PATH/${imageArray[$flash]} | cut -d "," -f1`G
							dd if=$IMAGE_PATH/${imageArray[$flash]} | pv -s $SIZE | dd of=$FLASH_DEVICE bs=8m
						else
							clear
							redColor
							echo "Please, change the device number"
							resetColor
						fi
					;;
				* ) clear
					redColor
					echo "Unknown file extension..."
					resetColor
					exit 1
				  ;;
			esac
		else
			if [ "$EXTENSION" == "gz" ]; then
				if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
					echo "Unmounted correctly"
					echo "Flashing, please wait..."
					echo ${imageArray[$flash]}
					gunzip -c $IMAGE_PATH/${imageArray[$flash]} | pv -s 7g | dd of=$FLASH_DEVICE bs=8m
				else
					clear
					redColor
					echo "Please, change the device number"
					resetColor
				fi
			fi
		fi
	fi
	exit 0
else
	clear
	redColor
	echo "\"sudo\" is needed..."
	resetColor
	exit 1
fi