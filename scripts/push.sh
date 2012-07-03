#!/bin/bash
#
# push new fw

source `dirname $0`/common.sh

USAGE="usage: $0 [-h \"<hosts>\"] -f <sysupgrade fw.bin> -t <types to push to>"
while getopts  "h:f:t:" options; do
        case $options in
		f ) FW_PATH=$OPTARG;;
		h ) HOSTS=$OPTARG;;
		t ) TYPE=$OPTARG;;
		* ) fail $USAGE
        esac
done

[ -n "$TYPE" -a -z "$FW_PATH" ] && FW_PATH=`get_openwrt_img $TYPE sysupgrade`
FW=`basename $FW_PATH`
[ -z "$FW" ] && fail "please specify a firmware!"
[[ "$FW" != *sysupgrade* ]] && fail "need a sysupgrade image!"

if [ -z "$HOSTS" -a ! -z "$TYPE" ]; then
	HOSTS=`get_hosts -t $TYPE`
elif [ -z "$HOSTS" ]; then
	HOSTS=`get_hosts`
fi

for host in $HOSTS; do
        echo updating $host
        _scp $FW_PATH root@${host}.local:/tmp/ || { echo "${host}: couldn't copy fw!"; continue; }
        _ssh root@${host}.local "source /etc/profile && sysupgrade -n /tmp/${FW}" # can't really get the return code from here, so assume success :P
done

