#! /bin/bash

source `dirname $0`/common.sh

git clone git://nbd.name/openwrt.git --no-checkout
pushd openwrt
git checkout ${OPENWRT_COMMIT}
./scripts/feeds update
./scripts/feeds install -a
popd
