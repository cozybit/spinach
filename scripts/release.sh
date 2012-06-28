#!/bin/bash
#
# create a release

source `dirname $0`/common.sh

USAGE="usage: $0 [-t <type> | -a] -v <version>"
while getopts  "t:v:a" options; do
        case $options in
		t ) TYPE=$OPTARG;;
		v ) V=$OPTARG;;
		a ) ALL=yes;;
		* ) fail $USAGE
        esac
done

[ -z "$TYPE" -a -z "$ALL" ] && fail "please specify a node type!"
[ -z "$V" ] && fail "please specify a release version!"

TARGETS=$TYPE
[ "$ALL" == "yes" ] && TARGETS="$SPINACH_TYPES"

./scripts/fetch.sh
for target in $TARGETS; do
	./scripts/configure.sh -t $target
	echo "building release for $target"
	./scripts/build.sh >/dev/null || fail "$target build failed"
	mkdir -p releases/$V/$target/
	cp `get_openwrt_img $target factory` releases/$V/$target/plant_mesh-$target-factory.bin || fail
	cp `get_openwrt_img $target sysupgrade` releases/$V/$target/plant_mesh-$target-sysupgrade.bin || fail
done

# ok so we're not testing..
if $ALL == "yes"; then
	cp releases/RELEASE_NOTE_TEMPLATE releases/$V/RELEASE_NOTES
	vi releases/$V/RELEASE_NOTES
	cd releases/
	tar cvzf ../plant_mesh_$V.tgz $V/
	cd ../
fi

echo "release $V for $TARGETS done"
