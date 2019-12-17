#!/bin/bash

# Stop on the first sign of trouble
#set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi

function echo_yellow()
{
    echo -e "\033[1;33m$1\033[0m"
}

do_check_variable_type(){
    local a="$1"
    printf "%d" "$a" &>/dev/null && return 0
    printf "%d" "$(echo $a|sed 's/^[+-]\?0\+//')" &>/dev/null && return 0
    printf "%f" "$a" &>/dev/null && return 1
    [ ${#a} -eq 1 ] && return 2
    return 3
}

do_check_variable_type_echo(){
    local a="$1"
    printf "%d" "$a" &>/dev/null && echo "integer, return 0" && return 0
    printf "%d" "$(echo $a|sed 's/^[+-]\?0\+//')" &>/dev/null && echo "integer,return 0" && return 0
    printf "%f" "$a" &>/dev/null && echo "number,return 1" && return 1
    [ ${#a} -eq 1 ] && echo "char, return 2" && return 2
    echo "string, return 3" && return 3
}

function echo_model_info()
{
    echo_yellow "Please select your gateway model:"
    echo_yellow "*\t1.RAK831"
    echo_yellow "*\t2.RAK2245"
    echo_yellow "*\t3.RAK7243"
    echo_yellow "*\t4.RAK833(USB)"
    echo_yellow "*\t5.RAK2247(USB)"
    echo_yellow "*\t6.RAK833(SPI)"
    echo_yellow "*\t7.RAK2247(SPI)"
    echo_yellow  "Please enter 1-5 to select the model:\c"
}

function do_set_model_to_json()
{
    JSON_FILE=./rak/rak/rak_gw_model.json
    if [ $1 -eq 1 ]; then
        GW_MODEL=RAK831
        do_set_spi_to_json 1
    elif [ $1 -eq 2 ]; then
        GW_MODEL=RAK2245
        do_set_spi_to_json 1
    elif [ $1 -eq 3 ]; then
        GW_MODEL=RAK7243
        do_set_spi_to_json 1
    elif [ $1 -eq 4 ]; then
        GW_MODEL=RAK833
        do_set_spi_to_json 0
    elif [ $1 -eq 5 ]; then
        GW_MODEL=RAK2247
        do_set_spi_to_json 0
    elif [ $1 -eq 6 ]; then
        GW_MODEL=RAK833
        do_set_spi_to_json 1
    elif [ $1 -eq 7 ]; then
        GW_MODEL=RAK2247
        do_set_spi_to_json 1
    else
        # Never come here
        echo "error"
        return 1
    fi
    linenum=`sed -n "/gw_model/=" $JSON_FILE`
    sed -i "${linenum}c\\\\t\"gw_model\": \"$GW_MODEL\"," $JSON_FILE
}

function do_set_spi_to_json()
{
    JSON_FILE=./rak/rak/rak_gw_model.json
    
    linenum=`sed -n "/spi/=" $JSON_FILE`
    sed -i "${linenum}c\\\\t\"spi\": \"$1\"" $JSON_FILE
}

function do_set_model()
{
    echo_model_info
    while [ 1 -eq 1 ]
    do
        read RAK_MODEL
        if [ -z "$RAK_MODEL" ]; then
            echo_yellow "IF Please enter 1-7 to select the model:\c"
            continue
        fi

        do_check_variable_type $RAK_MODEL
        RET=$?

        if [ $RET -eq 0 ]; then
            if [ $RAK_MODEL -lt 1 ] || [ $RAK_MODEL -gt 7 ]; then
                echo_yellow "IF Please enter 1-7 to select the model:\c"
                continue
            else
                do_set_model_to_json $RAK_MODEL
                return 0
            fi
        else
            echo_yellow "IF Please enter 1-7 to select the model:\c"
            continue

        fi
    done
}

do_set_model

