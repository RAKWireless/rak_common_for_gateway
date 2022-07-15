#!/bin/bash

# Stop on the first sign of trouble
set -e

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh

if [ $UID != 0 ]; then
    echo_error "Operation not permitted. Forgot sudo?"
    exit 1
fi

source $SCRIPT_COMMON_FILE

mkdir -p /usr/local/rak/lora

mkdir /opt/ttn-gateway -p

pushd rak7243
./install.sh
popd

pushd rak2246
./install.sh
popd

pushd rak2247_usb
./install.sh
popd

pushd rak2247_spi
./install.sh
popd

pushd rak2287
./install.sh
popd

pushd rak5146
./install.sh
popd

pushd rak5147
./install.sh
popd

cp ./update_gwid.sh rak7243/packet_forwarder/lora_pkt_fwd/update_gwid.sh
cp ./start.sh  rak7243/packet_forwarder/lora_pkt_fwd/start.sh
cp ./set_eui.sh  rak7243/packet_forwarder/lora_pkt_fwd/set_eui.sh

cp ./update_gwid.sh rak2246/packet_forwarder/lora_pkt_fwd/update_gwid.sh
cp ./start.sh  rak2246/packet_forwarder/lora_pkt_fwd/start.sh
cp ./set_eui.sh  rak2246/packet_forwarder/lora_pkt_fwd/set_eui.sh

cp ./update_gwid.sh rak2247_usb/packet_forwarder/lora_pkt_fwd/update_gwid.sh
cp ./start.sh  rak2247_usb/packet_forwarder/lora_pkt_fwd/start.sh
cp ./set_eui.sh  rak2247_usb/packet_forwarder/lora_pkt_fwd/set_eui.sh

cp ./update_gwid.sh rak2247_spi/packet_forwarder/lora_pkt_fwd/update_gwid.sh
cp ./start.sh  rak2247_spi/packet_forwarder/lora_pkt_fwd/start.sh
cp ./set_eui.sh  rak2247_spi/packet_forwarder/lora_pkt_fwd/set_eui.sh

cp ./update_gwid.sh rak2287/packet_forwarder/lora_pkt_fwd/update_gwid.sh
cp ./start.sh  rak2287/packet_forwarder/lora_pkt_fwd/start.sh
cp ./set_eui.sh  rak2287/packet_forwarder/lora_pkt_fwd/set_eui.sh

cp ./update_gwid.sh rak5146/packet_forwarder/lora_pkt_fwd/update_gwid.sh
cp ./start.sh  rak5146/packet_forwarder/lora_pkt_fwd/start.sh
cp ./set_eui.sh  rak5146/packet_forwarder/lora_pkt_fwd/set_eui.sh

cp ./update_gwid.sh rak5147/packet_forwarder/lora_pkt_fwd/update_gwid.sh
cp ./start.sh  rak5147/packet_forwarder/lora_pkt_fwd/start.sh
cp ./set_eui.sh  rak5147/packet_forwarder/lora_pkt_fwd/set_eui.sh

cp rak7243 /usr/local/rak/lora/ -rf
cp rak2246 /usr/local/rak/lora/ -rf
cp rak2247_usb /usr/local/rak/lora/ -rf
cp rak2247_spi /usr/local/rak/lora/ -rf
cp rak2287 /usr/local/rak/lora/ -rf
cp rak5146 /usr/local/rak/lora/ -rf
cp rak5147 /usr/local/rak/lora/ -rf

cp ttn-gateway.service /lib/systemd/system/ttn-gateway.service

systemctl enable ttn-gateway.service

# add for dfu usb to spi chip of stm
apt install git gcc make autoconf automake libusb-1.0-0-dev
git clone git://git.code.sf.net/p/dfu-util/dfu-util
pushd dfu-util
./autogen.sh
./configure
make all
sudo make install
popd
