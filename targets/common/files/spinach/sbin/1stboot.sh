#!/bin/ash

. /etc/plantmesh.conf
. /etc/plantmesh_target.conf

. ${PM_SPINACH_DIR}/sbin/pm2uci.sh
. ${PM_SPINACH_DIR}/sbin/hostname.sh

echo "exit 0" > $0
