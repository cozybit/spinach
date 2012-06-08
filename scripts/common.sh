#!/bin/bash

. spinach.conf

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

[ -z ${SPINACH_DIR} -o `basename $PWD` == ${SPINACH_DIR} ] || fail "This script must be executed from ${DIR}\'s root directory"

# enumerate reachable nodes
# XXX: do this once during the configure step?
# we can configure this as a string of associative arrays where each entry also
# contains the type of the node. Need to change hostname to
# $HOST_BASE-$TYPE-$XXXX
export SPINACH_HOSTS=`avahi-browse -t -k _ssh._tcp | grep ${HOST_BASE} | awk '{print $7}'`
