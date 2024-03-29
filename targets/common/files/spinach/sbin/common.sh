#!/bin/ash

. ${PM_TARGET_ROOT}/etc/plantmesh.conf

# path to private passphraseless ssh key used for node logins, don't share this
# with anyone!
SSH_KEYFILE="${PM_TARGET_ROOT}/spinach/keys/dev_key"

fail () {
	echo $*
	exit 1
}

SSH_OPTS="-y -i $SSH_KEYFILE"
_ssh () {
	ssh $SSH_OPTS $*
}

_scp () {
	scp $SSH_OPTS $*
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
				case $PM_TYPES in
					*$target*);;
					*) fail "invalid type!";;
				esac
			;;
			* ) fail "unknown argument: $@";;
		esac
	done

	hosts=`avahi-browse -t -k _ssh._tcp | grep ${PM_HOST_BASE} | awk '{print $7}'`

	# filter by $target
	local matching_hosts=""
	if [ ! -z "$target" ]; then
		for host in $hosts; do
			case $host in
				*$target*)
					matching_hosts="${matching_hosts} ${host}";;
			esac
		done
	else
		matching_hosts="${hosts}"
	fi
	echo $matching_hosts
}

# deduce the mesh interface name
get_mesh_if () {
	echo `iw dev | grep mesh -B2 | grep Inter | awk '{print $2}'`
}

# deduce mesh vlan interface name
get_mesh_vlanif () {
	local meshif=`get_mesh_if`
	echo "$meshif.$PM_MESH_VLAN_PORT"
}

# add the mesh vlan interface, useful so as not to spread this around too much
add_mesh_vlanif () {
	vconfig add `get_mesh_if` $PM_MESH_VLAN_PORT
	ifconfig `get_mesh_vlanif` up
}
