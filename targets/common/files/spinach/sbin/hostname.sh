#!/bin/ash

# Set this hostname. Should be added to the startup scripts.
# expects several PM_* environment variables
# Runs once, then deletes itself.

DIGITS=`ifconfig -a | grep eth0 | awk '{print $5}' | cut -d':' -f5,6 | sed 's/://'`
HOSTNAME=${PM_HOST_BASE}-${PM_TYPE}-${DIGITS}

uci set system.@system[0].hostname=${HOSTNAME}
uci commit
echo "$(uci get system.@system[0].hostname)" > /proc/sys/kernel/hostname
