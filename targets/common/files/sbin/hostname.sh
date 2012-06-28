#!/bin/sh

# Set this hostname. Should be added to the startup scripts.
# Runs once, then deletes itself.

HOST_BASE=PM
DIGITS=`ifconfig | grep eth0 | awk '{print $5}' | cut -d':' -f5,6 | sed 's/://'`
HOSTNAME=${HOST_BASE}-${DIGITS}

uci set system.@system[0].hostname=${HOSTNAME}
uci commit
echo "$(uci get system.@system[0].hostname)" > /proc/sys/kernel/hostname

/etc/init.d/avahi-daemon restart

echo "exit 0" > $0
