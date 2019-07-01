#!/bin/bash

# Stop on the first sign of trouble
set -e

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh

do_get_gw_id()
{
    GATEWAY_EUI_NIC="eth0"
    if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
        GATEWAY_EUI_NIC="wlan0"
    fi

    if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
       echo ""
    fi
    GATEWAY_EUI=$(ip link show $GATEWAY_EUI_NIC | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
    GATEWAY_EUI=${GATEWAY_EUI^^}
    echo $GATEWAY_EUI
}

source $SCRIPT_COMMON_FILE

if [ $UID != 0 ]; then
    echo "Operation not permitted. Forgot sudo?"
    exit 1
fi

systemctl disable hciuart

apt install git ppp dialog jq minicom monit -y

cp gateway-config /usr/bin/
cp gateway-version /usr/bin/
cp rak /usr/local/ -rf

#JSON_FILE=/usr/local/rak/rak_gw_model.json
#GW_ID=`do_get_gw_id`
#linenum=`sed -n "/gw_id/=" $JSON_FILE`
#sed -i "${linenum}c\\\\t\"gw_id\": \"$GW_ID\"," $JSON_FILE

echo_success "Copy Rak file success!"
