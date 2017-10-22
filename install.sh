#!/bin/bash
if (whiptail --title "Service installation script" --yesno "Do you want to configure the host - lxc, fail2ban, ferm?" 8 78) then
	if [ "$(id -u)" != "0" ]; then
		whiptail --title "Error" --msgbox "This script must be run as sudo" 8 78
		exit 1
	else
		$(pwd)/script/lxc/install.sh
	fi
else
	echo "User selected No, exit status was $?."
fi
