#!/bin/ash
#
# translate PM_* variables exported by the parent into UCI-speak.
# This seems ugly, we might be better served by passing a config file..

# all nodes have a meshif (?)
local _DEVICE=`uci get wireless.mesh0.device`
if [ ! -z "$_DEVICE" ]; then
	[ ! -z "$PM_MESH_CHANNEL" ] && \
		uci set wireless.${_DEVICE}.channel=$PM_MESH_CHANNEL
	[ ! -z "$PM_MESH_HWMODE" ] && \
		uci set wireless.${_DEVICE}.hwmode=$PM_MESH_HWMODE
	[ ! -z "$PM_MESH_HTMODE" ] && \
		uci set wireless.${_DEVICE}.htmode=$PM_MESH_HTMODE
fi
uci set wireless.mesh0.mesh_id=$PM_MESHID
if [ ! -z "$PM_MESHKEY" ]; then
	uci set wireless.mesh0.mesh_key=$PM_MESHKEY
else
	uci delete wireless.mesh0.mesh_key
fi

# will just error if no ap0 exists, we don't care..
local _DEVICE=`uci get wireless.ap0.device`
if [ ! -z "$_DEVICE" ]; then
	[ ! -z "$PM_AP_CHANNEL" ] && \
		uci set wireless.${_DEVICE}.channel=$PM_AP_CHANNEL
	[ ! -z "$PM_AP_HWMODE" ] && \
		uci set wireless.${_DEVICE}.hwmode=$PM_AP_HWMODE
	[ ! -z "$PM_AP_HTMODE" ] && \
		uci set wireless.${_DEVICE}.htmode=$PM_AP_HTMODE
fi
uci set wireless.ap0.ssid=$PM_SSID
if [ ! -z "$PM_KEY" ]; then
	uci set wireless.ap0.encryption=psk2
	uci set wireless.ap0.key=$PM_KEY
else
	uci set wireless.ap0.encryption=none
fi

# provisioning interface
if [ $PM_TYPE == "core" ]; then
	uci set network.prov.ipaddr=$PM_PROV_CORE_IP
else
	uci set network.prov.ipaddr=$PM_PROV_NODE_IP
fi
uci set network.prov.netmask=255.255.255.0

uci commit

/etc/init.d/network restart
