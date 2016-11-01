#!/bin/bash

read -p "Name of the new image? " name
path="/Users/lander/ImagesFlash"
sudo diskutil umount /dev/disk2s1 
sudo dd if=/dev/rdisk2 bs=8m | gzip -c > $path/$name.img.gz
