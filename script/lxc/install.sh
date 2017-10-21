#!/bin/bash
apt-get -y install lxc libvirt0 libpam-cgroup libpam-cgfs bridge-utils ferm
brctl addbr br0
echo "
allow-hotplug br0
iface br0 inet static
	bridge_stp off 
        address 192.168.123.1
	broadcast 192.168.123.255
	netmask 255.255.255.0
	    " >> /etc/network/interfaces
ifup br0
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -f
cp $(pwd)/ferm.conf /etc/ferm/ferm.conf
systemctl reload ferm
