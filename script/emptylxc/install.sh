#!/bin/bash
PET=$(whiptail --title "LXC name" --inputbox "Input LXC name" 10 60 test 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus != 0 ]; then
	echo "Name lxc conteiner is empty? rerun install.sh 1"
	exit 1
else
	if [ -z "${PET// /}" ]
	then
		echo "Name lxc conteiner is empty? rerun install.sh 2"
		exit 1
	fi
fi

lxc-create -n $PET -t debian
sed -i 's/lxc.network.type = empty/lxc.network.type = veth/' /var/lib/lxc/$PET/config
sed -i '/lxc.network.type = veth/ a\lxc.network.link = br0 ' /var/lib/lxc/$PET/config
sed -i '/lxc.network.link = br0/ a\lxc.network.name = eth0 ' /var/lib/lxc/$PET/config
sed -i 's/iface eth0 inet dhcp/iface eth0 inet static/' /var/lib/lxc/$PET/rootfs/etc/network/interfaces
IP=$(nmap -sn -oG - 192.168.123.0/24 -v | grep Down | sed -n -e 2p | awk '{print $2}')
echo "     address $IP/24
     gateway 192.168.123.1
     # dns-* options are implemented by the resolvconf package, if installed
     dns-nameservers 8.8.8.8 8.8.4.4" >> /var/lib/lxc/$PET/rootfs/etc/network/interfaces
echo "nameserver 8.8.8.8" > /var/lib/lxc/$PET/rootfs/etc/resolv.conf
lxc-start -n $PET
