#!/bin/bash

. spinach.conf
. $DEPLOY_CONF

fail () {
	echo $*
	exit 1
}

_ssh () {
	ssh -i ${SSH_KEYFILE} $*
}

_scp () {
	scp -i ${SSH_KEYFILE} $*
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

[ -z ${SPINACH_DIR} -o `basename $PWD` == ${SPINACH_DIR} ] || fail "This script must be executed from ${DIR}\'s root directory"

# enumerate reachable nodes
# XXX: do this once during the configure step?
# we can configure this as a string of associative arrays where each entry also
# contains the type of the node. Need to change hostname to
# $HOST_BASE-$TYPE-$XXXX
export SPINACH_HOSTS=`avahi-browse -t -k _ssh._tcp | grep ${PM_HOST_BASE} | awk '{print $7}'`
