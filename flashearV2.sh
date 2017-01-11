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

####################
####     pv    #####
####################

EXISTSPV=`command -v pv`

# Clear screen
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
		# Bad number
		clear
		redColor
		echo "Invalid number, launch the script again and choose one number of the list"
		resetColor
		exit 1

	else
		# Clear screen
		clear
		flash=$(($flash-1))
		# Check file extension 
		EXTENSION=`echo $$IMAGE_PATH/${imageArray[$flash]} | cut -d "." -f3`
		if [ -z $EXTENSION ]; then
			EXTENSION=`echo $$IMAGE_PATH/${imageArray[$flash]} | cut -d "." -f2`
			case $EXTENSION in
				"img" ) # Check if 'pv' command exists
						if [ -z $EXISTSPV ]; then
							if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
								# Flash without progress bar
								echo "Unmounted correctly"
								echo "Flashing, please wait..."
								dd if=$IMAGE_PATH/${imageArray[$flash]} | dd of=$FLASH_DEVICE bs=8m
							else
								clear
								redColor
								echo "Please, change the device number"
								resetColor
								exit 1
							fi
						else
							# Flash with progress bar
							if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
								echo "Unmounted correctly"
								echo "Flashing, please wait..."
								SIZE=`du -h $IMAGE_PATH/${imageArray[$flash]} | cut -d "," -f1`G
								dd if=$IMAGE_PATH/${imageArray[$flash]} | pv -s $SIZE | dd of=$FLASH_DEVICE bs=8m
							else
								# Bad device number exit
								clear
								redColor
								echo "Please, change the device number"
								resetColor
								exit 1
							fi
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
				# Check if 'pv' command exists
				if [ -z $EXISTSPV ]; then
					if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
						# Flash without progress bar
						echo "Unmounted correctly"
						echo "Flashing, please wait..."
						gunzip -c $IMAGE_PATH/${imageArray[$flash]} | dd of=$FLASH_DEVICE bs=8m
					else
						# Bad device number exit
						clear
						redColor
						echo "Please, change the device number"
						resetColor
						exit 1
					fi
				else
					# Flash with progress bar
					if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
						echo "Unmounted correctly"
						echo "Flashing, please wait..."
						gunzip -c $IMAGE_PATH/${imageArray[$flash]} | pv -s 7g | dd of=$FLASH_DEVICE bs=8m
					else
						# Bad device number exit
						clear
						redColor
						echo "Please, change the device number"
						resetColor
						exit 1
					fi
				fi
			fi
		fi
	fi
	exit 0
else
	# Bad user
	clear
	redColor
	echo "\"sudo\" is needed..."
	resetColor
	exit 1
fi