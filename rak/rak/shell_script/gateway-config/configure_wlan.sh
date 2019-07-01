#!/bin/bash

do_enable_ap_mode()
{
    write_json_wifi_mode 1
    systemctl enable create_ap

    if [ -f "/sbin/wpa_supplicant" ]; then
        mv /sbin/wpa_supplicant /sbin/wpa_supplicant_bak
    fi
    dialog --title "Enable AP Mode" --msgbox "The AP mode will active after the operating system reboot." 5 70
}

do_enable_wifi_mode()
{
    write_json_wifi_mode 2
    systemctl disable create_ap

    if [ -f "/sbin/wpa_supplicant_bak" ]; then
        mv /sbin/wpa_supplicant_bak /sbin/wpa_supplicant
    fi

    dialog --title "Enable Wifi Mode" --msgbox "The Client mode will active after the operating system reboot." 5 70
}

do_modify_ssid_for_ap()
{
    echo "aaa"
    rm /tmp/rak_ssid -rf
    mkfifo /tmp/rak_ssid
    rm /tmp/rak_ap_pwd -rf
    mkfifo /tmp/rak_ap_pwd
    
    # get old ssid
    old_ap_ssid=`do_get_gateway_info wifi.ap_ssid`
    
    # get old pwd
    old_ap_pwd=`do_get_gateway_info wifi.ap_pwd`
    
    # dialog ip
    dialog --title "AP SSID" --nocancel --inputbox "SSID:" 10 40 "$old_ap_ssid" 2> /tmp/rak_ssid & 
    RET=$?

    if [ $RET -eq 1 ]; then
        clear
    elif [ $RET -eq 0 ]; then
        new_ap_ssid="$( cat /tmp/rak_ssid  )"
        rm /tmp/rak_ssid
        ssid_len=${#new_ap_ssid}
    fi

    #dialog pwd
    dialog --title "AP Password" --nocancel --inputbox "Password:" 10 40 "$old_ap_pwd"  2> /tmp/rak_ap_pwd &
    if [ $RET -ne 0 ]; then
    	clear
    else
        new_ap_pwd="$( cat /tmp/rak_ap_pwd  )"
        pwd_len=${#new_ap_pwd}
        rm /tmp/rak_ap_pwd

    fi

    if [ $ssid_len -eq 0 ] || [ $pwd_len -eq 0 ] || [ $pwd_len -lt 8 ] ||[ $pwd_len -gt 63 ]; then
        if [ $ssid_len -eq 0 ]; then
            dialog --title "Configure AP SSID" --msgbox "SSID cannot be empty." 5 28
        elif [ $pwd_len -eq 0 ] || [ $pwd_len -lt 8 ] ||[ $pwd_len -gt 63 ]; then
            dialog --title "Configure AP Password" --msgbox "Invalid passphrase length ${pwd_len} (expected: 8..63)." 5 52
        else
            clear
        fi
    else
        sed -i "26c SSID=$new_ap_ssid" /usr/local/rak/ap/create_ap.conf
        sed -i "27c PASSPHRASE=$new_ap_pwd" /usr/local/rak/ap/create_ap.conf

        write_json_ap_ssid $new_ap_ssid
        write_json_ap_pwd $new_ap_pwd
        dialog --title "Configute AP info" --msgbox "Modify AP info success.Changes will take effect after OS restart." 5 72
	fi

#    do_main_menu
}

do_add_new_ssid()
{
    rm /tmp/wifi_ssid -rf
    mkfifo /tmp/wifi_ssid
    rm /tmp/wifi_pwd -rf
    mkfifo /tmp/wifi_pwd
    dialog --title "Configure WIFI" --nocancel --inputbox "SSID:" 10 40  2> /tmp/wifi_ssid &
    if [ $RET -ne 0 ]; then
#    	do_main_menu
        echo "test"
        return 1
    fi
    dialog --title "Configure WIFI" --nocancel --inputbox "Password:" 10 40  2> /tmp/wifi_pwd &
    if [ $RET -ne 0 ]; then
#    	do_main_menu
    	return 1
    fi

    linenum=`sed -n '/update_config/=' /etc/wpa_supplicant/wpa_supplicant.conf`
    let linenum=linenum+1
    
    wifi_ssid="$( cat /tmp/wifi_ssid  )"
    wifi_pwd="$( cat /tmp/wifi_pwd  )"
    ssid_len=${#wifi_ssid}
    pwd_len=${#wifi_pwd}
    
    if [ $ssid_len -eq 0 ]; then
    	dialog --title "Configure WIFI" --msgbox "SSID cannot be empty." 5 28
#    	do_main_menu
        return 1
    fi
    
    if [ $pwd_len -eq 0 ] || [ $pwd_len -lt 8 ] ||[ $pwd_len -gt 63 ]; then
    	dialog --title "Configure WIFI" --msgbox "Invalid passphrase length ${pwd_len} (expected: 8..63)." 5 52
 #   	do_main_menu
        return 1
    else
        sed -i "${linenum}inetwork={\nssid=\"${wifi_ssid}\"\nkey_mgmt=WPA-PSK\npsk=\"${wifi_pwd}\"\n}" /etc/wpa_supplicant/wpa_supplicant.conf
        dialog --title "Configure WIFI" --msgbox "Add new SSID success.Configuration will take effect after OS restart" 5 72
    fi
}

do_configure_wlan_ip() {
    rm /tmp/wlan0_ip -rf
    mkfifo /tmp/wlan0_ip

    rm /tmp/wlan0_gw -rf
    mkfifo /tmp/wlan0_gw

    # get old ip
    old_wlan0_ip=`do_get_gateway_info wifi.wifi_ip`

    # dialog ip
    dialog --title "Set wlan0 IP" --nocancel --inputbox "IP:" 10 40 "$old_wlan0_ip" 2> /tmp/wlan0_ip & 
    RET=$?

    if [ $RET -eq 1 ]; then
        echo "error"
    elif [ $RET -eq 0 ]; then
        new_wlan0_ip="$( cat /tmp/wlan0_ip  )" 
        do_check_ipaddr $new_wlan0_ip
        RET_IP=$?
        rm /tmp/wlan0_ip
    fi

    # get old gw
    old_wlan0_gw=`do_get_gateway_info wifi.wifi_gw`

    # dialog wlan0 gw
    dialog --title "Set wlan0 gateway IP" --nocancel --inputbox "Gateway IP:" 10 40 "$old_wlan0_gw" 2> /tmp/wlan0_gw & 
    RET=$?

    if [ $RET -eq 1 ]; then
        echo "error"
    elif [ $RET -eq 0 ]; then
        new_wlan0_gw="$( cat /tmp/wlan0_gw  )" 
        do_check_ipaddr $new_wlan0_gw
        RET_GW=$?
        rm /tmp/wlan0_gw
    fi
    
    if [ $RET_IP -eq 1 ]; then
        dialog --title "Configure wlan0" --msgbox "Invalid IP address." 5 50
    elif [ $RET_GW -eq 1 ]; then
        dialog --title "Configure wlan0" --msgbox "Invalid Gateway IP address." 5 50
    else

        linenum=`sed -n '/RAK_wlan0_IP/=' /etc/dhcpcd.conf`
        let line_ip=linenum+2
        let line_gw=linenum+3

        sed -i "${line_ip}cstatic ip_address=${new_wlan0_ip}" /etc/dhcpcd.conf
        sed -i "${line_gw}cstatic routers=${new_wlan0_gw}" /etc/dhcpcd.conf
        write_json_wlan_ip ${new_wlan0_ip}
        write_json_wlan_gw ${new_wlan0_gw}
        dialog --title "Configure wlan0" --msgbox "Configure wlan0 success.Changes will take effect after OS restart." 5 70
    fi
}

do_configure_wifi() {
    default_item=`do_get_gateway_info wifi.wifi_mode`

    FUN=$(dialog --title "Configure wifi" --cancel-label "Cancel" --default-item $default_item --menu "Configuration options:" 12 60 20 \
    	1 "Enable AP Mode/Disable Client Mode"	\
        2 "Enable Client Mode/Disable AP Mode" \
        3 "Modify SSID and pwd for AP Mode"	\
        4 "Add New SSID for Client" \
        5 "Configure WLAN ip(When Client Mode)"	\
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_enable_ap_mode;;
            2) do_enable_wifi_mode;;
            3) do_modify_ssid_for_ap;;
            4) do_add_new_ssid;;
            5) do_configure_wlan_ip;;
        esac
    fi

    do_main_menu
}

