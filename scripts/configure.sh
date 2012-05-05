#! /bin/bash

DIR=spinach
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

[ `basename $PWD` == ${DIR} ] || { echo This script must be executed from ${DIR} root directory; exit -1; }

[ "${TARGET}" != "" ] || { echo Please, specify a valid target; echo ${USAGE}; exit -1; }

[ -d targets/${TARGET} ] || { echo The target \"${TARGET}\" does not exist. Please check targets/ directory for supported targets; exit -1; }

# create symbolic links to the target specific config files
ln -fs ../targets/${TARGET}/openwrt.config openwrt/.config
ln -fs ../targets/${TARGET}/files openwrt/

# copy openwrt .config file
cd openwrt && yes '' | make oldconfig &> /dev/null && cd ..
