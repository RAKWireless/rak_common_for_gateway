#!/bin/bash

do_get_json_value()
{
    # $1 key; $2 file
    Var1=$(jq .$1 $2)
    Var2=${Var1//\"/}
    echo $Var2
}

do_get_gateway_info()
{
    GATEWAY_CONFIG_INFO=/usr/local/rak/gateway-config-info.json
    do_get_json_value $1 $GATEWAY_CONFIG_INFO
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

write_json_gateway_info_no_comma()
{
    # $1 key; $2 value
    do_check_variable_type  $1
    RET=$?
    if [ $RET -eq 3 ]; then
        sed -i "s/^.*$1.*$/\"$1\":\"$2\"/" /usr/local/rak/gateway-config-info.json
    fi
}

