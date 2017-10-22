#!/bin/bash
apt-get update && apt-get -y upgrade
apt-get -y install lxc libvirt0 libpam-cgroup libpam-cgfs bridge-utils ferm fail2ban
ii="";for i in $(ip a | awk -F ":" '/^[0-9]/ {print $2}'); do if [[ "$i" != "lo" ]];then ii+=" $i";fi;done; sed -i "s/DEV_WORLD=()/DEV_WORLD=($ii)/" $(pwd)/script/lxc/ferm.conf
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
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -f
cp $(pwd)/script/lxc/ferm.conf /etc/ferm/ferm.conf
systemctl reload ferm
