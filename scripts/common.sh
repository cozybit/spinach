#!/bin/bash

PM_TARGET_ROOT=`dirname $0`/../targets/common/files

. spinach.conf
. `dirname $0`/common_core.sh

## Override SSH_OPTS on dev hosts where we have full openssh
SSH_OPTS="-o StrictHostKeyChecking=no -oBatchMode=yes -i $SSH_KEYFILE"

# print message and exit the script
# usage: die <message>
function die () {
    echo ${*}
    exit -1
}

# return openwrt image file path from type
# get_openwrt_img <node_type> <img_type>
get_openwrt_img() {

	case $1 in
		node)
			echo "openwrt/bin/ar71xx/openwrt-ar71xx-generic-ubnt-bullet-m-squashfs-${2}.bin"
		;;
		core|station)
			echo "openwrt/bin/ar71xx/openwrt-ar71xx-generic-ubnt-rspro-squashfs-${2}.bin"
		;;
		*)
			fail "couldn't get img path: unknown node type!"
		;;
	esac
}

# return latest openwrt release image file path from type
# get_openwrt_img <node_type> <img_type>
get_openwrt_img_release() {

	local target=$1
	local img_type=$2
	local v=`find releases/ -maxdepth 1 -type d | cut -f2 -d'/' | sort -r | head -n1`
	case $target in
		node|core|station)
			echo "releases/$v/$target/plant_mesh-$target-$img_type.bin"
		;;
		*)
			fail "couldn't get img path: unknown node type!"
		;;
	esac
}

[ -z ${SPINACH_DIR} -o `basename $PWD` == ${SPINACH_DIR} ] || fail "This script must be executed from ${DIR}\'s root directory"
