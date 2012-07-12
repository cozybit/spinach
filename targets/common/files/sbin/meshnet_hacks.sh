#!/bin/ash
# hack in mesh vlan

. /etc/plantmesh.conf
. /etc/plantmesh_target.conf

local base_ip=`basename $PM_IP_BASE .0.0`

# get meshif name
local meshif=`iw dev | grep mesh -B2 | grep Inter | awk '{print $2}'`
local vlanif="$meshif.$PM_MESH_VLAN_PORT"

# add mesh vlan if
vconfig add $meshif $PM_MESH_VLAN_PORT
ifconfig $vlanif up

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
