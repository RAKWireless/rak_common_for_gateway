#!/bin/bash

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh
source $SCRIPT_COMMON_FILE

# Stop on the first sign of trouble
set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi

RAK_GW_MODEL=`do_get_gw_model`
if [ "${RAK_GW_MODEL}" = "RAK7243" ] || [ "$1" = "create_img" ]; then
    if [ ! -d "/usr/local/rak/lte" ]; then mkdir "/usr/local/rak/lte" -p ; fi

    cp ppp-creator.sh /usr/local/rak/lte/
    cp rak-pppd.service /lib/systemd/system

    echo_success "Install LTE module success!\n"
    sleep 2
fi
