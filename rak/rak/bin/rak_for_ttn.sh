#!/bin/bash

source /usr/local/rak/shell_script/rak_common.sh
GATEWAY_CONFIG_INFO=/usr/local/rak/gateway-config-info.json

write_json_gateway_info()
{
    # $1 key; $2 value
    sed -i "s/^.*$1.*$/\"$1\":\"$2\",/" $GATEWAY_CONFIG_INFO
}

write_json_wifi_mode()
{
    # 数字 1/2
    write_json_gateway_info "wifi_mode" $1
}


rak_tag=0

if [ -f "/boot/rak_ap" ]; then
    systemctl enable create_ap
    write_json_wifi_mode 1
    echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
" > /etc/wpa_supplicant/wpa_supplicant.conf
    mv /boot/rak_ap /boot/rak_ap_delete
    rak_tag=1
fi


if [ -f "/boot/rak_wifi" ]; then
    echo "" >> /etc/wpa_supplicant/wpa_supplicant.conf
    cat /boot/rak_wifi >> /etc/wpa_supplicant/wpa_supplicant.conf
    mv /boot/rak_wifi /boot/rak_wifi_delete
    rak_tag=1
fi

if [ -f "/boot/rak_hostname" ]; then
    CURRENT_HOSTNAME=$(hostname)
    NEW_HOSTNAME=`cat /boot/rak_hostname`
    echo $NEW_HOSTNAME > /etc/hostname
    sed -i "s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/" /etc/hosts
    mv /boot/rak_hostname /boot/rak_hostname_delete
    rak_tag=1
fi

if [ $rak_tag -eq 1 ]; then
    reboot
fi
