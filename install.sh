#!/bin/bash
. $(pwd)/script/func.sh
if (whiptail --title "Service installation script" --yesno "Do you want to configure the host - lxc, fail2ban, ferm?" 8 78) then
	if [ "$(id -u)" != "0" ]; then
		whiptail --title "Error" --msgbox "This script must be run as sudo" 8 78
		exit 1
	else
		setuphost
	fi
fi
if [ "$(id -u)" != "0" ]; then
	whiptail --title "Error" --msgbox "This script must be run as sudo" 8 78
	exit 1
fi



OPTION=$(whiptail --title "Menu Dialog" --menu "Select the service to be installed" 15 60 4 \
	"1" "Empty LXC" \
	"2" "Mariadb+PhpMyAdmin" \
	"3" "Postfix+Dovecot+Postgresql+Postfixadmin+Roundcube"  3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
	case "$OPTION" in
		"1" )
			emptylxc
		;;
		"2" )
			mariadb
		;;
		"3" )
			postf
		;;
	esac
fi
