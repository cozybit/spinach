#!/bin/bash
#
# push new fw

source `dirname $0`/common.sh

USAGE="usage: $0 [-h \"<hosts>\"] -f <sysupgrade fw.bin>"
while getopts  "h:f:t:" options; do
        case $options in
		f ) FW_PATH=$OPTARG;;
		h ) HOSTS=$OPTARG;;
		t ) TYPE=$OPTARG;;
		* ) fail $USAGE
        esac
done

FW=`basename $FW_PATH`
[ -z "$FW" ] && fail "please specify a firmware!"
[[ "$FW" != *sysupgrade* ]] && fail "need a sysupgrade image!"

# XXX: use enumerated hosts, but this currently isn't safe since the node types
# are unknown. Disable for now.
# [ -z "$HOSTS" ] && HOSTS="$SPINACH_HOSTS"
[ -z "$HOSTS" ] && fail "please specify a host to push to or run ./scripts/configure to enumerate spinach targets"

for host in $HOSTS; do
        echo updating $host
        _scp $FW_PATH root@${host}.local:/tmp/ || { echo "${host}: couldn't copy fw!"; continue; } &
        _ssh root@${host}.local "source /etc/profile && sysupgrade /tmp/${FW}" & # can't really get the return code from here, so assume success :P
done

