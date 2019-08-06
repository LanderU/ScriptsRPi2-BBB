#!/bin/bash

: '

 Maintainer: Lander Usategui San Juan, e-mail: lander.usategui@gmail.com

'

DEVICE=""
IMAGE_PATH="/Users/lander/ImagesFlash" #Change for your path
cont=1
indexArrayDevices=0
deviceArray=( )
currentUser=$(whoami)

#####################
####  FUNCTIONS   ###
#####################
function checkUser()
{
	# Clear screen
  clear
	if [ "$currentUser" == "root" ]; then
		listDevices
	else
		# Bad user
		echo "\"sudo\" is needed..."
		exit 1
	fi
}

function listDevices()
{
  for i in $(df -h | cut -d " " -f 1 | grep "^/dev/"); do
    echo "$cont- "$i
    deviceArray[indexArrayDevices]=$i
    indexArrayDevices=$(($indexArrayDevices+1))
    cont=$((cont+1))
  done

  read -p "Choose the device: " device

  if [ $device -gt ${#deviceArray[@]} ] || [ $device -lt 0 ]; then
    #Bad device number
    echo "Invalid number, launch the script again and choose a number of the list."
    exit 1
  else
    device=$((device-1))
    DEVICE="${deviceArray[$device]}"
    createImage
  fi
}

function createImage()
{
  checkSD
  if [ "`diskutil unmountDisk $DEVICE 2>/dev/null`" ]; then
    echo "Unmounted correctly."
    read -p "Name of the new image? " name
    dd if=$DEVICE bs=8m | gzip -c > $IMAGE_PATH/$name.img.gz
    echo "Done, your image is storaged at $IMAGE_PATH"
  else
    echo "Unable to unmount the SD Card"
    exit 1
  fi


}

function checkSD()
{
  READ_ONLY=$(diskutil info $DEVICE | grep "Read-Only Media"| awk '{print $3}')
  if [ "$READ_ONLY" == "Yes" ]; then
    clear
    echo "Unable to flash your SD card, the SD is protected..."
    exit 1
  fi
}

function main()
{
  checkUser
}

#Start script
main
