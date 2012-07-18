#!/bin/ash
# hack in mesh vlan

. /etc/plantmesh.conf
. /etc/plantmesh_target.conf
. ${PM_SPINACH_DIR}/sbin/common.sh

local base_ip=`basename $PM_IP_BASE .0.0`
local vlanif=`get_mesh_vlanif`

add_mesh_vlanif

if [ $PM_TYPE = "core" ]; then
	killall dnsmasq
	ifconfig $vlanif $base_ip.0.1 netmask 255.255.0.0
	echo "
	# auto-generated config file from /etc/config/dhcp
	# mostly defaults, you may need to modify these in the future
	conf-file=/etc/dnsmasq.conf                       
	dhcp-authoritative         
	domain-needed     
	localise-queries
	read-ethers     
	bogus-priv 
	expand-hosts
	domain=lan
	server=/lan/  
	dhcp-option=3,$base_ip.0.1
	dhcp-option=6,$base_ip.0.1
	dhcp-leasefile=/tmp/dhcp.leases
	resolv-file=/tmp/resolv.conf.auto
	stop-dns-rebind                  
	rebind-localhost-ok
					      
	# meshnet                             
	dhcp-range=$base_ip.0.2,$base_ip.254.254,2h
	interface=$vlanif
	" > /etc/dnsmasq.conf
	dnsmasq -C /etc/dnsmasq.conf
else
	udhcpc -p /var/run/udhcpc-$vlanif.pid -t 0 -h `cat /proc/sys/kernel/hostname` -s '/etc/udhcpc.script' -b -i $vlanif &
fi
