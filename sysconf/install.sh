#!/bin/bash

# Stop on the first sign of trouble
set -e

img=$1

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh
source $SCRIPT_COMMON_FILE

if [ $UID != 0 ]; then
    echo_error "Operation not permitted. Forgot sudo?"
    exit 1
fi

if [[ $NEW_HOSTNAME == "" ]]; then NEW_HOSTNAME="rak-gateway"; fi
# Change hostname if needed
CURRENT_HOSTNAME=$(hostname)

if [[ $NEW_HOSTNAME != $CURRENT_HOSTNAME ]]; then
    echo "Updating hostname to '$NEW_HOSTNAME'..."
    hostname $NEW_HOSTNAME
    echo $NEW_HOSTNAME > /etc/hostname
    sed -i "s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/" /etc/hosts
fi

# add rak_script to rc.local
linenum=`sed -n '/rak_script/=' /etc/rc.local`
if [ ! -n "$linenum" ]; then
        set -a line_array
        line_index=0
        for linenum in `sed -n '/exit 0/=' /etc/rc.local`; do line_array[line_index]=$linenum; let line_index=line_index+1; done
        sed -i "${line_array[${#line_array[*]} - 1]}i/usr/local/rak/bin/rak_script" /etc/rc.local
fi

cp config.txt /boot/config.txt
cp motd /etc/motd -f

CMD_STR=`cat /boot/cmdline.txt`
echo "$CMD_STR modules-load=dwc2,g_ether" > /boot/cmdline.txt

./set_ip.sh $img

echo_success "Copy sys_config file success!"
