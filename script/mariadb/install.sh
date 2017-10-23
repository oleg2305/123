#!/bin/bash -x

lxc-create -n mariadb -t debian
sed -i 's/lxc.network.type = empty/lxc.network.type = veth/' /var/lib/lxc/mariadb/config
sed -i '/lxc.network.type = veth/ a\lxc.network.link = br0 ' /var/lib/lxc/mariadb/config
sed -i '/lxc.network.link = br0/ a\lxc.network.name = eth0 ' /var/lib/lxc/mariadb/config

sed -i 's/iface eth0 inet dhcp/iface eth0 inet static/' /var/lib/lxc/mariadb/rootfs/etc/network/interfaces
echo "     address 192.168.123.2/16
     gateway 192.168.123.1
     # dns-* options are implemented by the resolvconf package, if installed
     dns-nameservers 8.8.8.8 8.8.4.4" >> /var/lib/lxc/mariadb/rootfs/etc/network/interfaces

lxc-start -n mariadb

lxc-attach -n mariadb -- apt-get -y install apache2 php phpmyadmin mariadb-server php-imap mcrypt

PASSWORD=$(whiptail --title "Test Password Box" --passwordbox "Enter your password and choose Ok to continue." 10 60 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
	mysql -e "CREATE USER 'myadmin'@'localhost' IDENTIFIED BY $PASSWORD; GRANT ALL PRIVILEGES ON *.* TO 'myadmin'@'localhost' WITH GRANT OPTION;"
fi
