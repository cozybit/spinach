#! /bin/bash

source `dirname $0`/common.sh

[ -d openwrt ] && fail "ERROR: Default openwrt directory already exits. Aborting." 
git clone git://nbd.name/openwrt.git --no-checkout || fail "ERROR: git clone failed. Aborting. "
pushd openwrt
git checkout ${OPENWRT_COMMIT} || fail "ERROR: git checkout failed. Aborting."

# apply patches
git am ../patches/* || fail "ERROR: patches werent able to apply cleanly. Aborting."

# Clean out the feeds so we get the right rev on feeds update
./scripts/feeds clean

# update the feeds
./scripts/feeds update
./scripts/feeds install -a

popd > /dev/null

