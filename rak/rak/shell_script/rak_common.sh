#!/bin/bash

RAK_GW_INFO_JSON_FILE=/usr/local/rak/rak_gw_model.json
GATEWAY_CONFIG_INFO=/usr/local/rak/gateway-config-info.json

function echo_normal()
{
    echo -e $1
}

function echo_success()
{
    echo -e "\033[1;32m$1\033[0m"
}

function echo_error()
{
    echo -e "\033[1;31mERROR: $1\033[0m"
}

function echo_warn()
{
    echo -e "\033[1;33mWARNING: $1\033[0m"
}

do_get_json_value()
{
    # $1 key; $2 file
    Var1=$(jq .$1 $2)
    Var2=${Var1//\"/}
    echo $Var2
}

do_get_gateway_info()
{
    do_get_json_value gw_model $GATEWAY_CONFIG_INFO
}

do_get_lora_spi()
{
    do_get_json_value spi $RAK_GW_INFO_JSON_FILE
}

do_get_gw_model()
{
    do_get_json_value gw_model $RAK_GW_INFO_JSON_FILE
}

do_get_gw_version()
{
   do_get_json_value gw_version $RAK_GW_INFO_JSON_FILE
}

do_get_gw_id()
{
    GATEWAY_EUI_NIC="eth0"
    if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
        GATEWAY_EUI_NIC="wlan0"
    fi
        if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
        GATEWAY_EUI_NIC="usb0"
    fi

    if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
       echo ""
    fi
    GATEWAY_EUI=$(ip link show $GATEWAY_EUI_NIC | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
    GATEWAY_EUI=${GATEWAY_EUI^^}
    echo $GATEWAY_EUI
}

do_check_variable_type(){
    local a="$1"
    printf "%d" "$a" &>/dev/null && return 0
    printf "%d" "$(echo $a|sed 's/^[+-]\?0\+//')" &>/dev/null && return 0
    printf "%f" "$a" &>/dev/null && return 1
    [ ${#a} -eq 1 ] && return 2
    return 3
}

do_get_rpi_model()
{
    model=255
    text=`tr -d '\0' </proc/device-tree/model | grep -a 'Pi 3'`
    if [ ! -z "$text" ]; then
        model=3
    fi

    if [ $model -eq 255 ]; then
        text=`tr -d '\0' </proc/device-tree/model | grep -a 'Pi 4'`
        if [ ! -z "$text" ]; then
            model=4
        fi
    fi

    if [ $model -eq 255 ]; then
        text=`tr -d '\0' </proc/device-tree/model | grep -a 'Pi Z'`
        if [ ! -z "$text" ]; then
            model=0
        fi
    fi
    echo $model
}


