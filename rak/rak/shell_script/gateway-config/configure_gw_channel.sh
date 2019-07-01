#!/bin/bash

LORA_PKT_PATH=/opt/ttn-gateway/packet_forwarder/lora_pkt_fwd

do_restart_packet_forwarder() {
    docker stop rak_lora
    systemctl stop ttn-gateway
    systemctl start ttn-gateway
    RET=$?
    if [ $RET -eq 0 ]; then
        dialog --title "Restart packet-forwarder" --msgbox "The packet-forwarder has been restarted." 5 60
#    else
#        dialog --title "Restart packet-forwarder" --msgbox "Restart LoRa program failed, please try again to restart the program." 5 73
    fi
    if [ $# -eq 0 ]; then
        do_main_menu
    fi
}

do_copy_global_conf() {
    cp $LORA_PKT_PATH/global_conf/global_conf.$2.json $LORA_PKT_PATH/global_conf.json
#    write_json_server_freq $3
    if [ "$1" = "ttn" ]; then
        dialog --title "Server-plan configuration" --msgbox "Server-plan configuration has been copied." 5 60
        write_json_server_plan 1
    elif [ "$1" = "lora_server" ]; then
        write_json_server_plan 2
        do_set_lora_server_ip
        cp /etc/loraserver/loraserver.$2.toml /etc/loraserver/loraserver.toml
        do_if_proc_is_run "loraserver"
        RET=$?
        if [ $RET -eq 0 ]; then
            do_LoRa_Server restart
        fi
    elif [ "$1" = "lorawan" ]; then
        write_json_server_plan 3
        do_set_lora_server_ip
    fi

    do_restart_packet_forwarder 1
}

do_setup_ttn_channel_plan() {
#    default_item=`do_get_gateway_info lora_server.freq`
    default_item=1
    FUN=$(dialog --title "TTN Channel-plan configuration" --default-item $default_item --menu "Select the Channel-plan:" 18 60 12 \
        1 "AS_923" \
        2 "AU_915_928" \
        3 "CN_470_510" \
        4 "EU_863_870" \
        5 "IN_865_867" \
        6 "KR_920_923" \
        7 "RU_864_870" \
        8 "US_902_928" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        echo "test"
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_copy_global_conf "ttn" "as_923" 1;;
            2) do_copy_global_conf "ttn" "au_915_928" 2;;
            3) do_copy_global_conf "ttn" "cn_470_510" 3;;
            4) do_copy_global_conf "ttn" "eu_863_870" 4;;
            5) do_copy_global_conf "ttn" "in_865_867" 5;;
            6) do_copy_global_conf "ttn" "kr_920_923" 6;;
            7) do_copy_global_conf "ttn" "ru_864_870" 7;;
            8) do_copy_global_conf "ttn" "us_902_928" 8;;
        esac
    fi
}

do_set_lora_server_ip()
{
    rm /tmp/gate_server_ip -rf
    mkfifo /tmp/gate_server_ip
    default_item=`do_get_gateway_info lora_server.lora_server_ip`
    dialog --title "lora server IP" --nocancel --inputbox "SERVER_IP:" 10 40 "$default_item" 2> /tmp/gate_server_ip & 
    RET=$?
    if [ $RET -eq 1 ]; then
        echo "error"
    elif [ $RET -eq 0 ]; then
        gate_server_ip="$( cat /tmp/gate_server_ip  )"
        rm /tmp/gate_server_ip

        write_json_lora_server_ip "$gate_server_ip"
        do_check_ip_is_localhost "$gate_server_ip"
        RET=$?
        if [ $RET -eq 0 ]; then
#            sed -i "s/^.*RAK_LORA_SERVER_IP.*$/RAK_LORA_SERVER_IP=172.17.0.1/" /usr/local/rak/lora/rak.env
            gate_server_ip="172.17.0.1"
#        else
#            sed -i "s/^.*RAK_LORA_SERVER_IP.*$/RAK_LORA_SERVER_IP=$gate_server_ip/" /usr/local/rak/lora/rak.env
        fi

        sed -i "s/^.*server_address.*$/\t\"server_address\": \"$gate_server_ip\",/" /usr/local/rak/lora/global_conf.json
        sed -i "s/^.*RAK_LORA_SERVER_IP.*$/RAK_LORA_SERVER_IP=$gate_server_ip/" /usr/local/rak/lora/rak.env
    fi
}

do_setup_lora_server_channel_plan() {
#    default_item=`do_get_gateway_info lora_server.freq`
    default_item=1
    FUN=$(dialog --title "LoRaServer Channel-plan configuration" --default-item $default_item --menu "Server the Channel-plan:" 18 60 12 \
        1 "AS_923" \
        2 "AU_915_928" \
        3 "CN_470_510" \
        4 "EU_433" \
        5 "EU_863_870" \
        6 "IN_865_867" \
        7 "KR_920_923" \
        8 "RU_864_870" \
        9 "US_902_928" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        echo "error"

    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_copy_global_conf "lora_server" "as_923" 1;;
            2) do_copy_global_conf "lora_server" "au_915_928" 2;;
            3) do_copy_global_conf "lora_server" "cn_470_510" 3;;
            4) do_copy_global_conf "lora_server" "eu_433" 4;;
            5) do_copy_global_conf "lora_server" "eu_863_870" 5;;
            6) do_copy_global_conf "lora_server" "in_865_867" 6;;
            7) do_copy_global_conf "lora_server" "kr_920_923" 7;;
            8) do_copy_global_conf "lora_server" "ru_864_870" 8;;
            9) do_copy_global_conf "lora_server" "us_902_928" 9;;
        esac
    fi
}

do_setup_lorawan_server_channel_plan() {
#    default_item=`do_get_gateway_info lora_server.freq`
    default_item=1
    FUN=$(dialog --title "LoRaServer Channel-plan configuration" --default-item $default_item --menu "Server the Channel-plan:" 18 60 12 \
        1 "AS_923" \
        2 "AU_915_928" \
        3 "CN_470_510" \
        4 "EU_433" \
        5 "EU_863_870" \
        6 "IN_865_867" \
        7 "KR_920_923" \
        8 "RU_864_870" \
        9 "US_902_928" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        echo "error"

    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_copy_global_conf "lorawan" "as_923" 1;;
            2) do_copy_global_conf "lorawan" "au_915_928" 2;;
            3) do_copy_global_conf "lorawan" "cn_470_510" 3;;
            4) do_copy_global_conf "lorawan" "eu_433" 4;;
            5) do_copy_global_conf "lorawan" "eu_863_870" 5;;
            6) do_copy_global_conf "lorawan" "in_865_867" 6;;
            7) do_copy_global_conf "lorawan" "kr_920_923" 7;;
            8) do_copy_global_conf "lorawan" "ru_864_870" 8;;
            9) do_copy_global_conf "lorawan" "us_902_928" 9;;
        esac
    fi
}

do_setup_channel_plan() {
    # $1: concentrator type
    # $2: config suffix, eg ".gps"
    default_item=`do_get_gateway_info lora_server.server_plan`

    FUN=$(dialog --title "Server-plan configuration" --default-item $default_item --menu "Select the Server-plan:" 15 60 3 \
        1 "Server is TTN" \
        2 "Server is LoRaServer" \
        3>&1 1>&2 2>&3)
    RET=$?

    if [ $RET -eq 1 ]; then
        echo "test"
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_setup_ttn_channel_plan;;
            2) do_setup_lora_server_channel_plan ;;
        esac
    fi
    do_main_menu
}




