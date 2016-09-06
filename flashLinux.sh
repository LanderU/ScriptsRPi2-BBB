#!/bin/bash

: '

	Author: Lander Usategui email: lander@erlerobot.com
'


if [ `whoami` != "root"  ]; then
	zenity --info --text "Execute this script with \"sudo\"\n\n \tsudo ./flashLinux.sh"
else
	image=$(zenity --file-selection --title "Choose your OS")
	
	if [ `echo $?` != "0" ]; then
		zenity --error --title "Error" --text "Choose one OS"
	else
		device=$(zenity --file-selection --title "Choose your device")
		if [ `echo $?` != "0" ]; then
			zenity --error --title "Error" --text "Choose one device"
		else

			#Umount devices
			flashDevice=`ls $device`
			mountDevices=`ls $device*`

			for i in `ls $device*`; do
				sudo umount $mountDevices 2>/dev/null
			done

			#Check extension of the image

			case $(echo `expr "$image" : '.*\.\(.*\)$'`) in
				"gz") 
					(gunzip -c $image | dd of=$flashDevicebs=8M conv=sync,notrunc,noerror) | zenity --progress --pulsate --auto-close
					zenity --info --title "Done!!" --text "Remove your SD."
					;;
				"img") 
					(dd if=$image of=$flashDevice bs=8M conv=sync,notrunc,noerror) | zenity --progress --pulsate --auto-close
					zenity --info --title "Done!!" --text "Remove your SD."
					;;
				"xz")
					(xz -dkc $image > $flashDevice) |  zenity --progress --pulsate --auto-close
					zenity --info --title "Done!!" --text "Remove your SD."
					;;
				*)
					zenity --error --title "Error" --text "Not supported extension."
			esac

		fi
	fi
fi
