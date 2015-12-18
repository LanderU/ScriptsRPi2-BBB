sudo diskutil umount /dev/disk2s1 
sudo dd if=/dev/rdisk2 bs=8m | gzip -c > erle-brain1-Debian-14-12-2015.img.gz
