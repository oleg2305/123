#!/bin/bash
if (whiptail --title "Service installation script" --yesno "Do you want to configure the host - lxc, fail2ban, ferm?" 8 78) then
	$(pwd)/script/lxc/install.sh
else
	echo "User selected No, exit status was $?."
fi
