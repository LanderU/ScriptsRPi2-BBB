#! /bin/bash

diskutil unmountDisk /dev/disk2
cd ../ImagesFlash
gunzip -c erle-brain-2-blanco-25-11-15.img.gz | sudo dd of=/dev/rdisk2 bs=8m
