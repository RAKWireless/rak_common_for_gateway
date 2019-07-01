#!/bin/bash

do_configure_lan() {
    rm /tmp/eth0_ip -rf
    mkfifo /tmp/eth0_ip

    rm /tmp/eth0_gw -rf
    mkfifo /tmp/eth0_gw

    # get old ip
    old_eth0_ip=`do_get_gateway_info lan.lan_ip`

    # dialog ip
    dialog --title "Set eth0 IP" --nocancel --inputbox "IP:" 10 40 "$old_eth0_ip" 2> /tmp/eth0_ip & 
    RET=$?

    if [ $RET -eq 1 ]; then
        echo "error"
    elif [ $RET -eq 0 ]; then
        new_eth0_ip="$( cat /tmp/eth0_ip  )" 
        do_check_ipaddr $new_eth0_ip
        RET_IP=$?
        rm /tmp/eth0_ip
    fi

    # get old gw
    old_eth0_gw=`do_get_gateway_info lan.lan_gw`

    # dialog eth0 gw
    dialog --title "Set eth0 gateway IP" --nocancel --inputbox "Gateway IP:" 10 40 "$old_eth0_gw" 2> /tmp/eth0_gw & 
    RET=$?

    if [ $RET -eq 1 ]; then
        echo "error"
    elif [ $RET -eq 0 ]; then
        new_eth0_gw="$( cat /tmp/eth0_gw  )" 
        do_check_ipaddr $new_eth0_gw
        RET_GW=$?
        rm /tmp/eth0_gw
    fi
    
    if [ $RET_IP -eq 1 ]; then
        dialog --title "Configure LAN" --msgbox "Invalid IP address." 5 50
    elif [ $RET_GW -eq 1 ]; then
        dialog --title "Configure LAN" --msgbox "Invalid Gateway IP address." 5 50
    else

        linenum=`sed -n '/RAK_eth0_IP/=' /etc/dhcpcd.conf`
        let line_ip=linenum+2
        let line_gw=linenum+3

        sed -i "${line_ip}cstatic ip_address=${new_eth0_ip}" /etc/dhcpcd.conf
        sed -i "${line_gw}cstatic routers=${new_eth0_gw}" /etc/dhcpcd.conf
        write_json_lan_ip ${new_eth0_ip}
        write_json_lan_gw ${new_eth0_gw}
        dialog --title "Configure LAN" --msgbox "Configure LAN success.Changes will take effect after OS restart." 5 70
    fi

    do_main_menu
}
