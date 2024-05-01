#!/bin/bash
for usb in $(sudo dmesg | grep usb | grep Keychron | grep -o 'hidraw[0-9]\+')
do
	sudo chmod 600 /dev/$usb
done
