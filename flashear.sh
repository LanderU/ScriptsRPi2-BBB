#!/bin/bash

: '

 maintainer Lander Usategui, e-mail: lander.usategui@gmail.com

'


clear

# CONSTANTS
IMAGE_PATH="/Users/lander/ImagesFlash" #Change for your path
DEVICE="/dev/disk2" #Change for your device
FLASH_DEVICE="/dev/rdisk2" #Change for your device

cont=1
indexArray=0
imageArray=( )

for i in `ls $IMAGE_PATH`; do
	echo $cont"- "$i
	imageArray[$indexArray]=$i
	indexArray=$(($indexArray+1))
	cont=$(($cont+1))
done

read -p "Choose the image: " flash

if [ $flash -gt ${#imageArray[@]} ] || [ $flash -lt 0 ]; then
	clear
	echo "Invalid number, launch the script again and choose one number of the list"

else
	clear
	flash=$(($flash-1))
	diskutil unmountDisk $DEVICE
	echo "Flashing, please wait..."
	gunzip -c $IMAGE_PATH/${imageArray[$flash]} | sudo dd of=$FLASH_DEVICE bs=8m

fi
exit 0
