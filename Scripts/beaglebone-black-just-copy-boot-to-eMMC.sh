#!/bin/bash -e
#
# Copyright (c) 2013 Robert Nelson <robertcnelson@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

if ! id | grep -q root; then
	echo "must be run as root"
	exit
fi

unset boot_drive
boot_drive=$(LC_ALL=C lsblk -l | grep "/boot/uboot" | awk '{print $1}')

if [ "x${boot_drive}" = "x" ] ; then
	echo "Error: script halting, system unrecognized..."
	exit 1
fi

if [ "x${boot_drive}" = "xmmcblk0p1" ] ; then
	source="/dev/mmcblk0"
	destination="/dev/mmcblk1"
fi

if [ "x${boot_drive}" = "xmmcblk1p1" ] ; then
	source="/dev/mmcblk1"
	destination="/dev/mmcblk0"
fi

network_down () {
	echo "Network Down"
	exit
}

check_running_system () {
	if [ ! -f /boot/uboot/uEnv.txt ] ; then
		echo "Error: script halting, system unrecognized..."
		echo "unable to find: [/boot/uboot/uEnv.txt] is ${source}p1 mounted?"
		exit 1
	fi

	echo "-----------------------------"
	echo "debug copying: [${source}] -> [${destination}]"
	lsblk
	echo "-----------------------------"
}

check_dpkg () {
	LC_ALL=C dpkg --list | awk '{print $2}' | grep "^${pkg}$" >/dev/null || deb_pkgs="${deb_pkgs}${pkg} "
}

check_host_pkgs () {
	unset deb_pkgs
	pkg="dosfstools"
	check_dpkg
	pkg="initramfs-tools"
	check_dpkg
	pkg="rsync"
	check_dpkg
	pkg="u-boot-tools"
	check_dpkg

	if [ "${deb_pkgs}" ] ; then
		ping -c1 www.google.com | grep ttl >/dev/null 2>&1 || network_down
		echo "Installing: ${deb_pkgs}"
		apt-get update -o Acquire::Pdiffs=false
		apt-get -y install ${deb_pkgs}
		apt-get clean
	fi
}

update_boot_files () {
	if [ ! -f /boot/initrd.img-$(uname -r) ] ; then
		update-initramfs -c -k $(uname -r)
	else
		update-initramfs -u -k $(uname -r)
	fi

	if [ -f /boot/vmlinuz-$(uname -r) ] ; then
		cp -v /boot/vmlinuz-$(uname -r) /boot/uboot/zImage
	fi

	if [ -f /boot/initrd.img-$(uname -r) ] ; then
		cp -v /boot/initrd.img-$(uname -r) /boot/uboot/initrd.img
	fi

	mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n initramfs -d /boot/initrd.img-$(uname -r) /boot/uboot/uInitrd
}

flush_cache () {
	sync
	blockdev --flushbufs ${destination}
}

fdisk_toggle_boot () {
	fdisk ${destination} <<-__EOF__
	a
	1
	w
	__EOF__
	flush_cache
}

format_boot () {
	LC_ALL=C fdisk -l ${destination} | grep ${destination}p1 | grep '*' || fdisk_toggle_boot

	mkfs.vfat -F 16 ${destination}p1 -n boot
	flush_cache
}

mount_n_check () {
	umount ${destination}p1 || true
	umount ${destination}p2 || true
	flush_cache

	mkdir -p /tmp/boot/ || true
	if mount -t vfat ${destination}p1 /tmp/boot/ ; then
		if [ -f /tmp/boot/MLO ] ; then
			flush_cache
			umount ${destination}p1 || true
			format_boot
		else
			flush_cache
			umount ${destination}p1 || true
			echo "use: beaglebone-black-copy-microSD-to-eMMC.sh"
		fi
	else
		echo "use: beaglebone-black-copy-microSD-to-eMMC.sh"
	fi
}

write_failure () {
	echo "writing to [${destination}] failed..."

	if [ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ] ; then
		echo heartbeat > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo heartbeat > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo heartbeat > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo heartbeat > /sys/class/leds/beaglebone\:green\:usr3/trigger
	fi
	echo "-----------------------------"
	flush_cache
	umount ${destination}p1 || true
	umount ${destination}p2 || true
	exit
}

copy_boot () {
	mkdir -p /tmp/boot/ || true
	mount ${destination}p1 /tmp/boot/ -o sync
	#Make sure the BootLoader gets copied first:
	cp -v /boot/uboot/MLO /tmp/boot/MLO || write_failure
	flush_cache

	cp -v /boot/uboot/u-boot.img /tmp/boot/u-boot.img || write_failure
	flush_cache

	rsync -aAXv /boot/uboot/ /tmp/boot/ --exclude={MLO,u-boot.img,*bak,flash-eMMC.txt} || write_failure
	flush_cache

	unset root_uuid
	root_uuid=$(/sbin/blkid -s UUID -o value ${destination}p2)
	if [ "${root_uuid}" ] ; then
		root_uuid="UUID=${root_uuid}"
		device_id=$(cat /tmp/boot/uEnv.txt | grep mmcroot | grep mmcblk | awk '{print $1}' | awk -F '=' '{print $2}')
		if [ ! "${device_id}" ] ; then
			device_id=$(cat /tmp/boot/uEnv.txt | grep mmcroot | grep UUID | awk '{print $1}' | awk -F '=' '{print $3}')
			device_id="UUID=${device_id}"
		fi
		sed -i -e 's:'${device_id}':'${root_uuid}':g' /tmp/boot/uEnv.txt
	else
		root_uuid="${source}p2"
	fi
	flush_cache
	umount ${destination}p1 || true
}

fix_rootfs () {
	mkdir -p /tmp/rootfs/ || true
	mount ${destination}p2 /tmp/rootfs/

	unset boot_uuid
	boot_uuid=$(/sbin/blkid -s UUID -o value ${destination}p1)
	if [ "${boot_uuid}" ] ; then
		boot_uuid="UUID=${boot_uuid}"
	else
		boot_uuid="${source}p1"
	fi

	unset root_filesystem
	root_filesystem=$(mount | grep ${source}p2 | awk '{print $5}')
	if [ ! "${root_filesystem}" ] ; then
		root_filesystem=$(mount | grep "${root_uuid}" | awk '{print $5}')
	fi
	if [ ! "${root_filesystem}" ] ; then
		root_filesystem="auto"
	fi

	echo "# /etc/fstab: static file system information." > /tmp/rootfs/etc/fstab
	echo "#" >> /tmp/rootfs/etc/fstab
	echo "# Auto generated by: beaglebone-black-just-copy-boot-to-eMMC.sh" >> /tmp/rootfs/etc/fstab
	echo "#" >> /tmp/rootfs/etc/fstab
	echo "${root_uuid}  /  ${root_filesystem}  noatime,errors=remount-ro  0  1" >> /tmp/rootfs/etc/fstab
	echo "${boot_uuid}  /boot/uboot  auto  defaults  0  0" >> /tmp/rootfs/etc/fstab
	echo "debugfs         /sys/kernel/debug  debugfs  defaults          0  0" >> /tmp/rootfs/etc/fstab
	flush_cache
	umount ${destination}p2 || true

	if [ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ] ; then
		echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr3/trigger
	fi

	echo ""
	echo "This script has now completed it's task"
	echo "-----------------------------"
	echo "Note: Actually unpower the board, a reset [sudo reboot] is not enough."
	echo "-----------------------------"
}

check_running_system
check_host_pkgs
update_boot_files
mount_n_check
copy_boot
fix_rootfs
