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

# enumerate reachable nodes in a string
# get_hosts [-t <type>]
get_hosts () {
	local OPTIND
	local OPTARG
	local target=
	local hosts
	while getopts  "t:" options; do
		case $options in
			t )
				target=$OPTARG
				[[ "$SPINACH_TYPES" != *$target* ]] && fail "invalid type!"
			;;
			* ) fail "unknown argument: $@";;
		esac
	done

	hosts=`avahi-browse -t -k _ssh._tcp | grep ${PM_HOST_BASE} | awk '{print $7}'`

	# filter by $target
	if [ ! -z "$target" ]; then
		for host in $hosts; do
			[[ $host != *$target* ]] && hosts="${hosts/$host}"
		done
	fi
	echo $hosts
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
