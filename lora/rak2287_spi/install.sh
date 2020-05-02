#!/bin/bash

# Stop on the first sign of trouble
set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi

SCRIPT_DIR=$(pwd)

# Request gateway configuration data
# There are two ways to do it, manually specify everything
# or rely on the gateway EUI and retrieve settings files from remote (recommended)
echo "Gateway configuration:"

# Install LoRaWAN packet forwarder repositories
INSTALL_DIR="./"
if [ ! -d "$INSTALL_DIR" ]; then mkdir $INSTALL_DIR; fi
pushd $INSTALL_DIR

# Build LoRa gateway app

wget https://github.com/Lora-net/sx1302_hal/archive/V1.0.5.tar.gz -O ./rak2287.tar.gz

tar -zxvf ./rak2287.tar.gz
pushd sx1302_hal-1.0.5
make clean
rm libloragw/inc/loragw_stts751.h -f
rm loragw_hal.c libloragw/src/loragw_stts751.c -f
cp loragw_hal.c libloragw/src/loragw_hal.c -f

mkdir -p libloragw/packet_forwarder/lora_pkt_fwd
cp reset_lgw.sh libloragw/packet_forwarder/lora_pkt_fwd/reset_lgw.sh -f

cp Makefile libloragw/Makefile -f

make

cp libloragw/packet_forwarder . -rf

popd

cp global_conf $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/ -rf
cp global_conf/global_conf.eu_863_870.json $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/global_conf.json
sed -i "s/^.*server_address.*$/\t\"server_address\": \"127.0.0.1\",/" $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/global_conf.json
rm -f $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/local_conf.json

