#! /bin/bash

source `dirname $0`/common.sh
USAGE="./scripts/configure.sh -t <target>"

##TODO improve the option system
while getopts  "t:j:" options; do
        case $options in
                t ) TARGET=$OPTARG;;
                * ) echo ${USAGE}
                        exit 1;;
        esac
done

[ "$DEBUG" == 'y' ] && set -x

[ "${TARGET}" != "" ] || { echo Please, specify a valid target; echo ${USAGE}; exit -1; }

[ -d targets/${TARGET} ] || { echo The target \"${TARGET}\" does not exist. Please check targets/ directory for supported targets; exit -1; }

# copy generic overlay
rm -rf openwrt/files
cp -R targets/common/files openwrt/

# copy target specific config files
cp targets/${TARGET}/openwrt.config openwrt/.config
cp -R targets/${TARGET}/files openwrt/

# copy openwrt .config file
cd openwrt && yes '' | make oldconfig &> /dev/null && cd ..
