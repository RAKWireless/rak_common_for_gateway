#!/bin/bash
# script needs to be run with super privilege
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run with superuser privilege. Try 'sudo ./install.sh'\n"
  exit 1
fi

set -e

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh
source $SCRIPT_COMMON_FILE

apt-get install util-linux procps hostapd iproute2 iw haveged dnsmasq

if [ ! -d create_ap ]; then
    git clone https://github.com/oblique/create_ap
fi
cp Makefile_ap create_ap/Makefile
pushd create_ap
make install
popd
cp create_ap.service /lib/systemd/system/
cp create_ap.conf /usr/local/rak/ap

./set_ssid
#systemctl enable create_ap
#mv /sbin/wpa_supplicant /sbin/wpa_supplicant_bak

echo_success "Install ap success!"
