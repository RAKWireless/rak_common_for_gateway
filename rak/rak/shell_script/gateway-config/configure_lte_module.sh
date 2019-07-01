#!/bin/bash

do_enable_2013()
{
    write_json_lte_mode 1
    systemctl enable rak-pppd
    dialog --title "Enable LTE Module" --msgbox "The LTE module will power on after the operating system starts." 5 70
#    do_main_menu
}

do_disable_2013()
{
    write_json_lte_mode 2
    systemctl disable rak-pppd
    dialog --title "Disable LTE Module" --msgbox "The LTE module will not power on after the operating system starts." 5 71
#    do_main_menu
}

do_rak2013()
{
    # get lte module status
    default_item=`do_get_gateway_info lte_mode`

    FUN=$(dialog --title "LTE Module" --cancel-label "Cancel" --default-item $default_item --menu "Configuration options:" 10 60 20 \
        1 "Enable LTE Automatic Dial-up" \
        2 "Disable LTE Automatic Dial-up" \
        3>&1 1>&2 2>&3)
    RET=$?
    if [ $RET -eq 1 ]; then
        clear
    elif [ $RET -eq 0 ]; then
        case "$FUN" in
            1) do_enable_2013;;
            2) do_disable_2013;;
        esac
    fi
    do_main_menu
}

do_set_apn_name()
{
    # get old apn
    old_apn=`do_get_gateway_info apn.apn_name`

    # get old baud speed
    old_baud=`do_get_gateway_info apn.apn_baud`

    rm /tmp/apn_name -rf
    mkfifo /tmp/apn_name
    rm /tmp/band_speed -rf
    mkfifo /tmp/band_speed
    dialog --title "APN Name" --nocancel --inputbox "APN Name:" 10 40 "$old_apn" 2> /tmp/apn_name & 
    dialog --title "Baud Speed" --nocancel --inputbox "Baud Speed:" 10 40 "$old_baud" 2> /tmp/band_speed &
    RET=$?

    if [ $RET -eq 1 ]; then
        echo "error"
    elif [ $RET -eq 0 ]; then
        new_apn_name="$( cat /tmp/apn_name  )" 
        new_baud_speed="$( cat /tmp/band_speed  )"

        RET2=`do_check_variable_type $new_baud_speed`
        if [ $RET2 -ne 0 ]; then
            dialog --title "Baud Speed" --msgbox "Invalid baud speed." 5 40
        else
            /usr/local/rak/lte/ppp-creator.sh "${new_apn_name}" ttyAMA0 ${new_baud_speed} >/dev/null
    	    rm /tmp/apn_name -rf
    	    rm /tmp/band_speed -rf

    	    write_json_apn_name $new_apn_name
    	    write_json_apn_baud $new_baud_speed
        fi
    fi
    do_main_menu
}
