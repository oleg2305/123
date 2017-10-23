#!/bin/bash

lxc-create -n emptylxc -t debian
sed -i 's/lxc.network.type = empty/lxc.network.type = veth/' /var/lib/lxc/emptylxc/config
sed -i '/lxc.network.type = veth/ a\lxc.network.link = br0 ' /var/lib/lxc/emptylxc/config
sed -i '/lxc.network.link = br0/ a\lxc.network.name = eth0 ' /var/lib/lxc/emptylxc/config


sed -i 's/iface eth0 inet dhcp/iface eth0 inet static/' /var/lib/lxc/emptylxc/rootfs/etc/network/interfaces
echo "     address 192.168.123.3/16
     gateway 192.168.123.1
     # dns-* options are implemented by the resolvconf package, if installed
     dns-nameservers 8.8.8.8 8.8.4.4" >> /var/lib/lxc/emptylxc/rootfs/etc/network/interfaces
echo "nameserver 8.8.8.8" > /var/lib/lxc/emptylxc/rootfs/etc/resolv.conf
lxc-start -n emptylxc
