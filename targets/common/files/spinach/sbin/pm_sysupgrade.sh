#!/bin/ash

# A simple shell script to allow sysupgrade to run unattended, in the
# background, after SLEEPTIME seconds

FW_FILE=${2}
SLEEPTIME=${1}

source `dirname $0`/common.sh
source /etc/profile

[ -f "${FW_FILE}" ] || fail "firmware ${FW_FILE} does not exist!"

( sleep ${SLEEPTIME}; sysupgrade -n "${FW_FILE}" &> /tmp/sysupgrade.log & )
