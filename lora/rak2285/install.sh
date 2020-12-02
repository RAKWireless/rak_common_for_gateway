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

wget https://github.com/Lora-net/sx1302_hal/archive/V1.0.5.tar.gz -O ./rak2285.tar.gz

tar -zxvf ./rak2285.tar.gz
#mv sx1302_hal-1.0.5 lora_gateway
pushd sx1302_hal-1.0.5
make clean
rm libloragw/inc/loragw_stts751.h -f
rm libloragw/src/loragw_stts751.c -f
cp ../loragw_hal.c libloragw/src/loragw_hal.c -f

#mkdir -p packet_forwarder/lora_pkt_fwd/
#cp ../reset_lgw.sh packet_forwarder/lora_pkt_fwd/reset_lgw.sh -f
cp ../Makefile libloragw/Makefile -f
cp ../lora_pkt_fwd.c packet_forwarder/src/lora_pkt_fwd.c
make
rm packet_forwarder/lora_pkt_fwd/obj/* -f
popd

pushd sx1302_hal-1.0.5/libloragw
make clean
popd

if [ -d $INSTALL_DIR/packet_forwarder ]; then
    rm -rf $INSTALL_DIR/packet_forwarder/
fi
cp $INSTALL_DIR/sx1302_hal-1.0.5/packet_forwarder $INSTALL_DIR/ -rf
mv $INSTALL_DIR/packet_forwarder/lora_pkt_fwd $INSTALL_DIR/packet_forwarder/lora_pkt_fwd_bak
mkdir -p $INSTALL_DIR/packet_forwarder/lora_pkt_fwd
mv $INSTALL_DIR/packet_forwarder/lora_pkt_fwd_bak $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/lora_pkt_fwd
cp global_conf $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/ -rf
cp global_conf/global_conf.eu_863_870.json $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/global_conf.json
cp reset_lgw.sh $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/reset_lgw.sh
sed -i "s/^.*server_address.*$/\t\"server_address\": \"127.0.0.1\",/" $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/global_conf.json
rm -f $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/local_conf.json
