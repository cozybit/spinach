#! /bin/bash

OPENWRT_COMMIT=7877ca154f130fe0c83a5f151320c3ce902195d1
DIR=spinach

[ `basename $PWD` == ${DIR} ] || { echo This script must be executed from ${DIR}\'s root directory; exit -1; }

git clone git://nbd.name/openwrt.git --no-checkout
cd openwrt
git checkout ${OPENWRT_COMMIT}
./scripts/feeds update
./scripts/feeds install -a
cd ..
