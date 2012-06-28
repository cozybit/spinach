#!/bin/ash
#
# translate PM_* variables exported by the parent into UCI-speak.
# This seems ugly, we might be better served by passing a config file..

# all nodes have a meshif (?)
uci set wireless.mesh0.mesh_id=$PM_MESHID
if [ ! -z "$PM_MESHKEY" ]; then
	uci set wireless.mesh0.mesh_key=$PM_MESHKEY
else
	uci delete wireless.mesh0.mesh_key
fi

# will just error if no ap0 exists, we don't care..
uci set wireless.ap0.ssid=$PM_SSID
if [ ! -z "$PM_KEY" ]; then
	uci set wireless.ap0.encryption=psk2
	uci set wireless.ap0.key=$PM_KEY
else
	uci set wireless.ap0.encryption=none
fi

# TODO: mesh/ap channels, hwmode, etc.

uci commit
/etc/init.d/network restart
