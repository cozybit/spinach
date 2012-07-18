#!/bin/ash
#
# push new fw and run sysupgrade on targets

source `dirname $0`/common.sh

THIS_HOST=`cat /proc/sys/kernel/hostname`

# push_fw <fw_image> <hosts>
# saves new fw_image on hosts
push_fw()  {
	local fw_path=$1
	local hosts=$2
	local fw=`basename $fw_path`
	local host=""

	[ -z "$fw" ] && fail "please specify a firmware!"
	case "$fw" in
		*sysupgrade*) ;;
		*) fail "need a sysupgrade image!";;
	esac
	[ -f "$fw_path" ] || fail "firmware $fw_path does not exist!"

	for host in $hosts; do
		if [ "${host}" != "${THIS_HOST}" ]; then 
			echo "uploading $fw to $host"
			_scp "${fw_path}" root@${host}:/tmp/ || { echo "${host}: couldn't copy fw!"; continue; }
		fi
	done
}

# push_sysupgrade <hosts> <sleeptime> <fw_file>
# commands host to sleep and run sysupgrade
push_sysupgrade()  {
	local hosts="${1}"
	local sleeptime="${2}"
	local fw_file="${3}"
	local host=""

	#local SSH_OPTS="${SSH_OPTS} -f"
	[ -z "$fw_file" ] && fail "please specify a firmware!"

	for host in $hosts; do
		if [ "${host}" != "${THIS_HOST}" ]; then 
			echo "sysupgrade on $host with `basename $fw_file`"
			_ssh root@${host} "/spinach/sbin/pm_sysupgrade.sh ${sleeptime} /tmp/${fw_file}"
		fi
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

case ${THIS_HOST} in
	## if we are running on core, we can push to all targets,
	## then ask them to wait SLEEPTIME and sysupgrade.
	## gives core time to run its own sysupgrade and reboot first
	*core*)
		SLEEPTIME=60
		if [ -n "$ALL" ]; then
			for target in $PM_TYPES; do
				for host in `get_hosts -t ${target}`; do
					push_fw `get_openwrt_target_img_path "/tmp" "${target}" sysupgrade` "${host}"
				done
			done
			for target in $PM_TYPES; do
				for host in `get_hosts -t ${target}`; do
					push_sysupgrade "${host}" $SLEEPTIME plant_mesh-${target}-sysupgrade.bin
				done
			done
			# run sysupgrade on core while the others are sleeping
			( sysupgrade -n `get_openwrt_target_img_path "/tmp" "core" sysupgrade` &> /tmp/sysupgrade.log & )
		else
			fail "updating pm members individually from core not supported, try -a"
		fi
		;;
	## if we are running from dev host (because its not core)
	*)
		SLEEPTIME=0

		## updating all hosts is accomplished by pushing the firmware images to core
		## and asking core to distribute them to targets and perform sysupgrade
		if [ -n "$ALL" ]; then
			for target in $PM_TYPES; do
				push_fw `get_openwrt_img_release $target sysupgrade` "`get_hosts -t core`".local
			done
			_ssh root@"`get_hosts -t core`".local /spinach/sbin/push.sh -a
		## updating individual targets, or all of a certain type from devhost
		## requires avahi discovery of targets and routes from dev host
		else
			[ -n "$TYPE" -a -z "$FW_PATH" ] && FW_PATH=`get_openwrt_img_release $TYPE sysupgrade`
			if [ -z "$HOSTS" -a ! -z "$TYPE" ]; then
				HOSTS=`get_hosts -t $TYPE`
			elif [ -z "$HOSTS" ]; then
				HOSTS=`get_hosts`
			fi

			for host in ${HOSTS}; do
				push_fw $FW_PATH "${host}".local
				push_sysupgrade "$host".local $SLEEPTIME `basename $FW_PATH`
			done
		fi
		;;
esac
