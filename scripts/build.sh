#! /bin/bash

source `dirname $0`/common.sh

cd openwrt
yes '' | make -j$SPINACH_JOBS $*
