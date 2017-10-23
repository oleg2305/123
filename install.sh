#!/bin/bash
if (whiptail --title "Service installation script" --yesno "Do you want to configure the host - lxc, fail2ban, ferm?" 8 78) then
	if [ "$(id -u)" != "0" ]; then
		whiptail --title "Error" --msgbox "This script must be run as sudo" 8 78
		exit 1
	else
		$(pwd)/script/lxc/install.sh
	fi
fi
OPTION=$(whiptail --title "Menu Dialog" --menu "Select the service to be installed" 15 60 4 \
	"1" "Mariadb+PhpMyAdmin" \
	"2" "Grilled Halloumi Cheese" \
	"3" "Charcoaled Chicken Wings" \
	"4" "Fried Aubergine"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
	if [ $OPTION = 1 ]; then
		$(pwd)/script/mariadb/install.sh
	fi
fi
