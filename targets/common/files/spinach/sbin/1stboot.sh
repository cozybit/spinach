#!/bin/ash

. /etc/plantmesh.conf
. /etc/plantmesh_target.conf

. ${PM_SPINACH_DIR}/sbin/hostname.sh
# apply plantmesh network configuration
. ${PM_SPINACH_DIR}/sbin/pm2uci.sh

# fix avahi now we have a new hostname
/etc/init.d/avahi-daemon restart

echo "exit 0" > $0
