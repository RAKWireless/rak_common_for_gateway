#!/bin/bash

# Stop on the first sign of trouble
#set -e

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh
source $SCRIPT_COMMON_FILE

if [ $UID != 0 ]; then
    echo_error "Operation not permitted. Forgot sudo?"
    exit 1
fi

write_json_gateway_info_no_comma()
{
    # $1 key; $2 value
    do_check_variable_type  $1
    RET=$?
    if [ $RET -eq 3 ]; then
        sed -i "s/^.*$1.*$/\"$1\":\"$2\"/" /usr/local/rak/gateway-config-info.json
    fi
}

write_json_gateway_info()
{
    # $1 key; $2 value
    do_check_variable_type  $1
    RET=$?
    if [ $RET -eq 3 ]; then
        sed -i "s/^.*$1.*$/\"$1\":\"$2\",/" /usr/local/rak/gateway-config-info.json
    fi
}

write_json_lan_ip()
{
    # 数字 . 校验下是否为有效IP
    write_json_gateway_info "lan_ip" $1
}

write_json_lan_gw()
{
    # 数字 . 校验下是否为有效IP
    write_json_gateway_info_no_comma "lan_gw" $1
}

write_json_wlan_ip()
{
    # 数字 . 校验下是否为有效IP
    write_json_gateway_info "wifi_ip" $1
}

write_json_wlan_gw()
{
    # 数字 . 校验下是否为有效IP
    write_json_gateway_info "wifi_gw" $1
}

get_inte_ip()
{
    IP_ADDR=`ifconfig $1|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
    echo $IP_ADDR
}

get_gw_by_ip()
{
    newip=$(echo $1 |cut -f 1-3 -d .)
    echo $newip
}

get_inte_ip wlan0

eth0_ip=`get_inte_ip eth0`

if [ -z "$eth0_ip" ]; then
    echo "eth0 ip null"
    eth0_ip="192.168.10.10"
    eth0_gw="192.168.10.1"
else
    echo "eth0_ip:$eth0_ip"
    eth0_gw=`get_gw_by_ip $eth0_ip`".1"
fi

echo "
# WARNING:Do not delete or modify the following 5 lines!!!
# RAK_eth0_IP
interface eth0
static ip_address=${eth0_ip}
static routers=${eth0_gw}
static domain_name_servers=8.8.8.8 223.5.5.5" >> /etc/dhcpcd.conf

echo_success "Set eth0 IP address:$eth0_ip"
sleep 5
