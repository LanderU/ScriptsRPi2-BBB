# Linux

# DEPRECATED

## With flashLinux script you can flash your SD.

![](https://github.com/LanderU/ScriptsRPi2-BBB/.github/workflows/main.yml/badge.svg)

Dependencies
=======

`sudo apt-get install zenity -y`

Requirements
=========

Launch the script with `sudo`

`sudo ./flashLinux.sh`


# MAC OSX

Dependencies
=======

* [HomeBrew](http://brew.sh/index_es.html)

* `brew install pv`

## With [flashMAC.sh](https://github.com/LanderU/ScriptsRPi2-BBB/blob/master/flashMAC.sh) script you can flash your SD under MAC OSX.

**Note**: change path of the images on the script.

# Kernel

The [folder](https://github.com/LanderU/ScriptsRPi2-BBB/tree/master/Kernel) contain a simple script to deploy the differents kernel (not include).

# WiFi (WIP)

Simple script to configure the WiFi. Connect to internet or hotspot.

## Change the branch

If you need use BBB scripts, change to BBB branch, `git checkout BBB`, or you can clone only the BBB branch: 

```
git clone --single-branch -b BBB https://github.com/LanderU/ScriptsRPi2-BBB
```

### Problems?

Open an [issue](https://github.com/LanderU/ScriptsRPi2-BBB/issues/new).
