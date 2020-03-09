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

# Check dependencies
echo "Installing dependencies..."
apt-get -y install git libftdi-dev libusb-dev

# Build libraries

if [ ! -d libmpsse ]; then
    git clone https://github.com/devttys0/libmpsse.git
fi
pushd libmpsse/src
./configure --disable-python
make
make install
ldconfig
popd

# Install LoRaWAN packet forwarder repositories
INSTALL_DIR="./"
if [ ! -d "$INSTALL_DIR" ]; then mkdir $INSTALL_DIR; fi
pushd $INSTALL_DIR

# Build LoRa gateway app

if [ ! -d $SCRIPT_DIR/../lora_gateway ]; then
    git clone https://github.com/Lora-net/lora_gateway.git
else
    cp $SCRIPT_DIR/../lora_gateway . -rf
fi
pushd lora_gateway

cp ./libloragw/99-libftdi.rules /etc/udev/rules.d/99-libftdi.rules
cp $SCRIPT_DIR/loragw_spi.ftdi.c ./libloragw/src/
cp $SCRIPT_DIR/Makefile-gw-lib ./libloragw/Makefile
cp $SCRIPT_DIR/Makefile-lbt-test ./util_lbt_test/Makefile
cp $SCRIPT_DIR/Makefile-pkt-logger ./util_pkt_logger/Makefile
cp $SCRIPT_DIR/Makefile-spectral-scan ./util_spectral_scan/Makefile
cp $SCRIPT_DIR/Makefile-spi-stress ./util_spi_stress/Makefile
cp $SCRIPT_DIR/Makefile-tx-continuous ./util_tx_continuous/Makefile
cp $SCRIPT_DIR/Makefile-tx-test ./util_tx_test/Makefile
cp $SCRIPT_DIR/library.cfg ./libloragw/
cp $SCRIPT_DIR/Makefile-gw ./Makefile

sed -i -e 's/CFG_SPI= native/CFG_SPI= ftdi/g' ./libloragw/library.cfg

make
popd

# Build packet forwarder
if [ ! -d $SCRIPT_DIR/../packet_forwarder ]; then
    git clone https://github.com/Lora-net/packet_forwarder.git
else
    cp $SCRIPT_DIR/../packet_forwarder . -rf
fi
pushd packet_forwarder

cp $SCRIPT_DIR/Makefile-pk ./lora_pkt_fwd/Makefile
cp $SCRIPT_DIR/lora_pkt_fwd.c ./lora_pkt_fwd/src/lora_pkt_fwd.c

make

popd

cp global_conf $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/ -rf
cp global_conf/global_conf.eu_863_870.json $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/global_conf.json
sed -i "s/^.*server_address.*$/\t\"server_address\": \"127.0.0.1\",/" $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/global_conf.json
rm -f $INSTALL_DIR/packet_forwarder/lora_pkt_fwd/local_conf.json
