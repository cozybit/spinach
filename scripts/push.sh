#!/bin/bash
#
# push new fw

source `dirname $0`/common.sh

# push_fw <fw_image> <hosts>
push_fw()  {
	local fw_path=$1
	local hosts=$2
	local fw=`basename $fw_path`

	[ -z "$fw" ] && fail "please specify a firmware!"
	[[ "$fw" != *sysupgrade* ]] && fail "need a sysupgrade image!"

	for host in $hosts; do
		echo updating $host
		_scp $fw_path root@${host}.local:/tmp/ || { echo "${host}: couldn't copy fw!"; continue; }
		_ssh root@${host}.local "source /etc/profile && sysupgrade -n /tmp/${fw}"
	done

	# XXX: check all nodes came back up
}

USAGE="usage: $0 [-h \"<hosts>\"] -f <sysupgrade fw.bin> -t <types to push to>"
while getopts  "h:f:t:a" options; do
        case $options in
		a ) ALL=YES;;
		f ) FW_PATH=$OPTARG;;
		h ) HOSTS=$OPTARG;;
		t ) TYPE=$OPTARG;;
		* ) fail $USAGE
        esac
done

if [ -n "$ALL" ]; then
	for target in $SPINACH_TYPES; do
		push_fw `get_openwrt_img_release $target sysupgrade` "`get_hosts -t $target`"
	done
else
	[ -n "$TYPE" -a -z "$FW_PATH" ] && FW_PATH=`get_openwrt_img_release $TYPE sysupgrade`
	if [ -z "$HOSTS" -a ! -z "$TYPE" ]; then
		HOSTS=`get_hosts -t $TYPE`
	elif [ -z "$HOSTS" ]; then
		HOSTS=`get_hosts`
	fi

	push_fw $FW_PATH "$HOSTS"
fi
