#!/bin/bash

# Stop on the first sign of trouble
set -e

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh
JSON_FILE=/usr/local/rak/rak_gw_model.json
GLOBAL_SUB_DIR=serial

if [ $UID != 0 ]; then
    echo_error "Operation not permitted. Forgot sudo?"
    exit 1
fi

source $SCRIPT_COMMON_FILE

apt-get install erlang-base erlang-crypto erlang-syntax-tools erlang-inets erlang-mnesia erlang-runtime-tools erlang-ssl erlang-public-key erlang-asn1 erlang-os-mon erlang-snmp erlang-xmerl -y
dpkg -i lorawan-server_0.6.7_all.deb

sudo sed -i 's#1680#1700#g' /usr/lib/lorawan-server/releases/0.6.7/sys.config

systemctl disable lorawan-server
systemctl stop lorawan-server

echo_success "\nLoraWan installed successfully.\n"

