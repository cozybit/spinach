#!/bin/bash
#
# create a release

source `dirname $0`/common.sh

USAGE="usage: $0 -t <type> -v <version>"
while getopts  "t:v:" options; do
        case $options in
		t ) TYPE=$OPTARG;;
		v ) V=$OPTARG;;
		* ) fail $USAGE
        esac
done

[ -z "$TYPE" ] && fail "please specify a node type!"
[ -z "$V" ] && fail "please specify a release version!"

./scripts/fetch.sh
./scripts/configure.sh -t $TYPE
./scripts/build.sh || fail

mkdir -p releases/$V/$TYPE/
cp `get_openwrt_img $TYPE factory` releases/$V/$TYPE/plant_mesh-$TYPE-factory.bin
cp `get_openwrt_img $TYPE sysupgrade` releases/$V/$TYPE/plant_mesh-$TYPE-sysupgrade.bin

echo "release $V for $TYPE done"
