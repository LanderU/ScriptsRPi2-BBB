#!/bin/sh

#Based off:
#https://github.com/beagleboard/meta-beagleboard/blob/master/meta-beagleboard-extras/recipes-support/usb-gadget/gadget-init/g-ether-load.sh

SERIAL_NUMBER=$(hexdump -e '8/1 "%c"' /sys/bus/i2c/devices/0-0050/eeprom -s 14 -n 2)-$(hexdump -e '8/1 "%c"' /sys/bus/i2c/devices/0-0050/eeprom -s 16 -n 12)
ISBLACK=$(hexdump -e '8/1 "%c"' /sys/bus/i2c/devices/0-0050/eeprom -s 8 -n 4)

BLACK=""

if [ "${ISBLACK}" = "BBBK" ] ; then
	BLACK="Black"
fi

if [ "${ISBLACK}" = "BNLT" ] ; then
	BLACK="Black"
fi

mac_address="/proc/device-tree/ocp/ethernet@4a100000/slave@4a100200/mac-address"
if [ -f ${mac_address} ] ; then
	cpsw_0_mac=$(hexdump -v -e '1/1 "%02X" ":"' ${mac_address} | sed 's/.$//')
	echo "cpsw.0: ${cpsw_0_mac}"
fi

mac_address="/proc/device-tree/ocp/ethernet@4a100000/slave@4a100300/mac-address"
if [ -f ${mac_address} ] ; then
	cpsw_1_mac=$(hexdump -v -e '1/1 "%02X" ":"' ${mac_address} | sed 's/.$//')
	echo "cpsw.1: ${cpsw_1_mac}"
fi

modprobe g_multi file=/dev/mmcblk0p1 cdrom=0 stall=0 removable=1 nofua=1 iSerialNumber=${SERIAL_NUMBER} iManufacturer=Circuitco  iProduct=BeagleBone${BLACK} host_addr=${cpsw_1_mac}

sleep 1

if [ -f /etc/default/udhcpd ] ; then
	unset udhcp_disabled
	udhcp_disabled=$(grep \#DHCPD_ENABLED /etc/default/udhcpd || true)
	if [ "x${udhcp_disabled}" = "x" ] ; then
		sed -i -e 's:DHCPD_ENABLED="no":#DHCPD_ENABLED="no":g' /etc/default/udhcpd
	fi
fi

if [ -f /etc/udhcpd.conf ] ; then
	#Distro default...
	unset deb_udhcpd
	deb_udhcpd=$(grep Sample /etc/udhcpd.conf || true)
	if [ ! "x${deb_udhcpd}" = "x" ] ; then
		mv /etc/udhcpd.conf /etc/udhcpd.conf.bak

		echo "start      192.168.7.1" > /etc/udhcpd.conf
		echo "end        192.168.7.1" >> /etc/udhcpd.conf
		echo "interface  usb0" >> /etc/udhcpd.conf
		echo "max_leases 1" >> /etc/udhcpd.conf
		echo "option subnet 255.255.255.252" >> /etc/udhcpd.conf
	fi
	/etc/init.d/udhcpd restart

	/sbin/ifconfig usb0 192.168.7.2 netmask 255.255.255.252
	/usr/sbin/udhcpd -S /etc/udhcpd.conf
fi
