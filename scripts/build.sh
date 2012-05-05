#! /bin/bash

[ `basename $PWD` == "spinach" ] || { echo This script must be executed from the spinach\'s root directory; exit -1; }

cd openwrt
yes '' | make $*
