#!/bin/bash

: '

 Maintainer Lander Usategui San Juan, e-mail: lander.usategui@gmail.com

'

#####################
####  CONSTANTS   ###
#####################
# CONSTANTS
IMAGE_PATH="/Users/lander/ImagesFlash" #Change for your path
DEVICE="/dev/disk2" #Change for your device
FLASH_DEVICE="/dev/rdisk2" #Change for your device
# USER
currentUser=`whoami`
# Array
cont=1
indexArray=0
imageArray=( )

#####################
####  FUNCTIONS   ###
#####################

function checkPV()
{
	EXISTSPV=`command -v pv`
	if [ -z $EXISTSPV ]; then
		EXISTSPV="false"
	else
		EXISTSPV="true"
	fi
	echo $EXISTSPV
}

function checkUser()
{
	# Clear screen
	clear
	if [ $currentUser == "root" ]; then
		checkImage
	else
		# Bad user
		redColor
		echo "\"sudo\" is needed..."
		resetColor
		exit 1
	fi
}

function checkImage()
{
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
		flashSd
	fi
}

function flashSd()
{
	# Clear screen
	clear
	flash=$(($flash-1))
	# Check file extension
	EXTENSION=`echo $IMAGE_PATH/${imageArray[$flash]} | cut -d "." -f3`
	# Empty?
	if [ -z $EXTENSION ]; then
		# Check again
		EXTENSION=`echo $IMAGE_PATH/${imageArray[$flash]} | cut -d "." -f2`
		case $EXTENSION in
			"img") # Check PV
				   if [ $( checkPV ) == "true" ]; then
				   		# Flash with progress bar
						if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
							echo "Unmounted correctly"
							echo "Flashing, please wait..."
							SIZE=`du -h $IMAGE_PATH/${imageArray[$flash]} | cut -d "," -f1`G
							if [ "`dd if=$IMAGE_PATH/${imageArray[$flash]} | pv -s $SIZE | dd of=$FLASH_DEVICE bs=8m 2>/dev/null`" ]; then
							         if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
								           clear
								           echo -e "Done\nRemove your SD Card"
								           exit 0
							         else
								           echo "Unable to unmount the SD Card"
							         fi
              else
                clear
                echo "Unable to flash your SD card, the SD is protected..."
              fi
						else
							# Bad device number exit
							clear
							redColor
							echo "Please, change the device number"
							resetColor
							exit 1
						fi
				   else
				   		if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
							# Flash without progress bar
							echo "Unmounted correctly"
							echo "Flashing, please wait..."
							if [ "`dd if=$IMAGE_PATH/${imageArray[$flash]} | dd of=$FLASH_DEVICE bs=8m 2>/dev/null`" ]; then
  							if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
  								clear
  								echo -e "Done\nRemove your SD Card"
  								exit 0
  							else
  								echo "Unable to unmount the SD Card"
  							fi
              else
                clear
                echo "Unable to flash your SD card, the SD is protected..."
              fi
						else
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
		case $EXTENSION in
			"gz") 	# Check PV
				   if [ $( checkPV ) == "true" ]; then
				   		# Flash with progress bar
						if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
							echo "Unmounted correctly"
							echo "Flashing, please wait..."
							SIZE=`du -h $IMAGE_PATH/${imageArray[$flash]} | cut -d "," -f1`G
							if [ "`gunzip -c $IMAGE_PATH/${imageArray[$flash]} | pv -s 7g | dd of=$FLASH_DEVICE bs=8m 2>/dev/null`" ]; then
  							if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
  								clear
  								echo -e "Done\nRemove your SD Card"
  								exit 0
  							else
  								echo "Unable to unmount the SD Card"
  							fi
              else
                clear
                echo "Unable to flash your SD card, the SD is protected..."
              fi
						else
							# Bad device number exit
							clear
							redColor
							echo "Please, change the device number"
							resetColor
							exit 1
						fi
				   else
				   		if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
							# Flash without progress bar
							echo "Unmounted correctly"
							echo "Flashing, please wait..."
							if [ "`gunzip -c $IMAGE_PATH/${imageArray[$flash]} | dd of=$FLASH_DEVICE bs=8m 2>/dev/null`" ]; then
  							if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
  								clear
  								echo -e "Done\nRemove your SD Card"
  								exit 0
  							else
  								echo "Unable to unmount the SD Card"
  							fi
              else
                clear
                echo "Unable to flash your SD card, the SD is protected..."
              fi
						else
							clear
							redColor
							echo "Please, change the device number"
							resetColor
							exit 1
						fi
				   fi
			;;
			"img")
					EXTENSION=`echo $IMAGE_PATH/${imageArray[$flash]} | cut -d "." -f4`
					if [ -z $EXTENSION ]; then
					   # Check PV
					    if [ $( checkPV ) == "true" ]; then
					   		# Flash with progress bar
							if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
								echo "Unmounted correctly"
								echo "Flashing, please wait..."
								SIZE=`du -h $IMAGE_PATH/${imageArray[$flash]} | cut -d "," -f1`G
								if [ "`dd if=$IMAGE_PATH/${imageArray[$flash]} | pv -s $SIZE | dd of=$FLASH_DEVICE bs=8m 2>/dev/null`" ]; then
  								if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
  									clear
  									echo -e "Done\nRemove your SD Card"
  									exit 0
  								else
  									echo "Unable to unmount the SD Card"
  								fi
                else
                  clear
                  echo "Unable to flash your SD card, the SD is protected..."
                fi
							else
								# Bad device number exit
								clear
								redColor
								echo "Please, change the device number"
								resetColor
								exit 1
							fi
					    else
					   		if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
								# Flash without progress bar
								echo "Unmounted correctly"
								echo "Flashing, please wait..."
								if [ "`dd if=$IMAGE_PATH/${imageArray[$flash]} | dd of=$FLASH_DEVICE bs=8m`" ]; then
  								if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
  									clear
  									echo -e "Done\nRemove your SD Card"
  									exit 0
  								else
  									echo "Unable to unmount the SD Card"
  								fi
                else
                  clear
                  echo "Unable to flash your SD card, the SD is protected..."
                fi
							else
								clear
								redColor
								echo "Please, change the device number"
								resetColor
								exit 1
							fi
					    fi
					else
						echo "zip version?? extract image first..."
						exit 1
					fi
			;;
			* ) clear
				redColor
				echo "Unknown file extension..."
				resetColor
				exit 1
			;;
		esac
	fi
}

# COLORS

function redColor()
{
	tput setaf 1
} # End red color

function resetColor()
{
	tput sgr 0
} # End Reset color

function main()
{
	checkUser
}

# Start script
main
