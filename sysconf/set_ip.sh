#!/bin/bash

# Stop on the first sign of trouble
#set -e

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh
source $SCRIPT_COMMON_FILE

if [ $UID != 0 ]; then
    echo_error "Operation not permitted. Forgot sudo?"
    exit 1
fi

if [ "$1" = "create_img" ]; then
    echo "
# WARNING:Do not delete or modify the following 5 lines!!!
# RAK_eth0_IP
interface eth0
static ip_address=192.168.10.10
static routers=192.168.10.1" >> /etc/dhcpcd.conf

else
    echo ""
fi


#echo_success "Set eth0 IP address:$eth0_ip"
sleep 5
