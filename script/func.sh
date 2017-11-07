#!/bin/bash

setuphost ()
{
	apt-get update && apt-get -y upgrade
	apt-get -y install lxc libvirt0 libpam-cgroup libpam-cgfs bridge-utils ferm fail2ban nmap tcpdump
	cp $(pwd)/script/ferm.conf /etc/ferm/ferm.conf
	ii="";for i in $(ip a | awk -F ":" '/^[0-9]/ {print $2}'); do if [[ "$i" != "lo" ]];then ii+=" $i";fi;done; sed -i "s/DEV_WORLD=()/DEV_WORLD=($ii)/" /etc/ferm/ferm.conf
	brctl addbr br0
	echo "
	allow-hotplug br0
	iface br0 inet static
        	bridge_stp off 
        	address 192.168.123.1
        	broadcast 192.168.123.255
        	netmask 255.255.255.0
		pre-up brctl addbr br0
		post-down brctl delbr br0
            	" >> /etc/network/interfaces
	ifup br0
	echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
	sysctl -f
	systemctl reload ferm
}
emptylxc ()
{
	PET=$(whiptail --title "LXC name" --inputbox "Input LXC name" 10 60 test 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus != 0 ]; then
        	echo "Name lxc conteiner is empty? rerun install.sh"
        	exit 1
	else
        	if [ -z "${PET// /}" ]
        	then
                	echo "Name lxc conteiner is empty? rerun install.sh"
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
}
mariadb ()
{
	emptylxc
	lxc-attach -n $PET -- apt-get -y install apache2 php phpmyadmin mariadb-server php-imap mcrypt
	PASSWORD=$(whiptail --title "Password phpmyadmin" --passwordbox "Enter password for user myadmin  and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)

	exitstatus=$?
	if [ $exitstatus = 0 ]; then
        	lxc-attach -n $PET --  mysql -e "CREATE USER 'myadmin'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON *.* TO 'myadmin'@'localhost' WITH GRANT OPTION;"
	fi
	echo "&FORWARD(tcp, \$DEV_WORLD, 80, $IP);" >> /etc/ferm/ferm.conf
	systemctl reload ferm
}

postf ()
{
	emptylxc
	cp $(pwd)/script/postfix.sh /var/lib/lxc/$PET/rootfs/root/
	lxc-attach -n $PET -- /root/postfix.sh
}
