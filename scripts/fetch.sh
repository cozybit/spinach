#! /bin/bash

source `dirname $0`/common.sh

git clone git://nbd.name/openwrt.git --no-checkout
pushd openwrt
git checkout ${OPENWRT_COMMIT}

# apply patches
git am ../patches/*

# Clean out the feeds so we get the right rev on feeds update
./scripts/feeds clean

# update the feeds
./scripts/feeds update
./scripts/feeds install -a

popd > /dev/null

