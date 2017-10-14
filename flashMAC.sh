#!/bin/bash

: '

 Maintainer Lander Usategui San Juan, e-mail: lander.usategui@gmail.com

'

#set -x

#####################
####  CONSTANTS   ###
#####################
# CONSTANTS
IMAGE_PATH="/Users/lander/ImagesFlash" #Change for your path
DEVICE=""
FLASH_DEVICE=""
# USER
currentUser=`whoami`
# Array
cont=1
cont2=1
indexArray=0
indexArrayDevices=0
imageArray=( )
deviceArray=( )

#####################
####  FUNCTIONS   ###
#####################
function listDevices()
{
  for i in `df -h | cut -d " " -f 1 | grep "^/dev/"`; do
    if [ "$i" != "/dev/disk1" ]; then # Avoid show OS hdd
      echo $cont2"- "$i
      deviceArray[indexArrayDevices]=$i
      indexArrayDevices=$(($indexArrayDevices+1))
      cont2=$(($cont2+1))
    fi
  done

  if [ $cont2 -eq 1 ]; then # Check if we've available some resource
    redColor
    echo "No devices found, insert your SD Card..."
    resetColor
    exit 1
  fi
  read -p "Choose the device: " device

  if [ $device -gt ${#deviceArray[@]} ] || [ $device -lt 0 ]; then
    #Bad device number
    clear
    redColor
    echo "Invalid number, launch the script again and choose a number of the list."
    resetColor
    exit 1
  else
    device=$(($device-1))
    DEVICE="${deviceArray[$device]}"
    NUMBER_DISK=(`echo $DEVICE | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//'`)
    UNMOUNT_DEVICE=(`echo "/dev/disk"$NUMBER_DISK`)
    FLASH_DEVICE="/dev/rdisk$NUMBER_DISK"
    clear
    checkImage
  fi
}

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
		listDevices
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
		echo "Invalid number, launch the script again and choose a number of the list."
		resetColor
		exit 1
	else
		flashSd
	fi
}

function checkSD()
{
  READ_ONLY=`diskutil info $UNMOUNT_DEVICE | grep "Read-Only Media"| awk '{print $3}'`
  if [ $READ_ONLY == "Yes" ]; then
    clear
    redColor
    echo "Unable to flash your SD card, the SD is protected..."
    resetColor
    exit 1
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
              checkSD
						if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
							echo "Unmounted correctly"
							echo "Flashing, please wait..."
							SIZE=`du -h $IMAGE_PATH/${imageArray[$flash]} | cut -d "," -f1`G
							dd if=$IMAGE_PATH/${imageArray[$flash]} | pv -s $SIZE | dd of=$FLASH_DEVICE bs=8m 2>/dev/null
							if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
							         clear
						           echo -e "Done\nRemove your SD Card"
								       exit 0
							else
                       clear
                       redColor
								       echo "Unable to unmount the SD Card"
                       resetColor
                       exit 1
							fi
						fi
				   else
              					checkSD
				   		if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
							# Flash without progress bar
							echo "Unmounted correctly"
							echo "Flashing, please wait..."
							dd if=$IMAGE_PATH/${imageArray[$flash]} | dd of=$FLASH_DEVICE bs=8m 2>/dev/null
  						if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
  								clear
  								echo -e "Done\nRemove your SD Card"
  								exit 0
  						else
                  clear
                  redColor
  								echo "Unable to unmount the SD Card"
                  resetColor
                  exit 1
  						fi
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
            					checkSD
						if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
							echo "Unmounted correctly"
							echo "Flashing, please wait..."
							SIZE=`du -h $IMAGE_PATH/${imageArray[$flash]} | cut -d "," -f1`G
							gunzip -c $IMAGE_PATH/${imageArray[$flash]} | pv -s 7g | dd of=$FLASH_DEVICE bs=8m 2>/dev/null
  						if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
  							  clear
  								echo -e "Done\nRemove your SD Card"
  								exit 0
  						else
                  clear
                  redColor
  								echo "Unable to unmount the SD Card"
                  resetColor
                  exit 1
  						fi
						fi
				   else
              					checkSD
				   		if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
							# Flash without progress bar
							echo "Unmounted correctly"
							echo "Flashing, please wait..."
							gunzip -c $IMAGE_PATH/${imageArray[$flash]} | dd of=$FLASH_DEVICE bs=8m 2>/dev/null
  						if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
  								clear
  								echo -e "Done\nRemove your SD Card"
  								exit 0
  						else
                  clear
                  redColor
  								echo "Unable to unmount the SD Card"
                  resetColor
                  exit 1
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
              checkSD
					    if [ $( checkPV ) == "true" ]; then
					   		# Flash with progress bar
							if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
								echo "Unmounted correctly"
								echo "Flashing, please wait..."
								SIZE=`du -h $IMAGE_PATH/${imageArray[$flash]} | cut -d "," -f1`G
								dd if=$IMAGE_PATH/${imageArray[$flash]} | pv -s $SIZE | dd of=$FLASH_DEVICE bs=8m 2>/dev/null
  							if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
  									clear
  									echo -e "Done\nRemove your SD Card"
  									exit 0
  							else
                    clear
                    redColor
  									echo "Unable to unmount the SD Card"
                    resetColor
                    exit 1
  							fi
							fi
					    else
                #check SD
                checkSD
					   		if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
  								# Flash without progress bar
  								echo "Unmounted correctly"
  								echo "Flashing, please wait..."
  								dd if=$IMAGE_PATH/${imageArray[$flash]} | dd of=$FLASH_DEVICE bs=8m
    							if [ "`diskutil unmountDisk $UNMOUNT_DEVICE 2>/dev/null`" ]; then
    									clear
    									echo -e "Done\nRemove your SD Card"
    									exit 0
    							else
                      clear
                      redColor
    									echo "Unable to unmount the SD Card"
                      resetColor
                      exit 1
    							fi
                fi
					    fi
					else
            redColor
						echo "zip version?? extract image first..."
            resetColor
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
