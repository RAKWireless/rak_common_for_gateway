#!/bin/bash

# Stop on the first sign of trouble
set -e

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh

if [ $UID != 0 ]; then
    echo_error "Operation not permitted. Forgot sudo?"
    exit 1
fi

if [ ! -d lora_gateway ]; then
    git clone https://github.com/Lora-net/lora_gateway.git
else
    pushd lora_gateway
    git pull
    popd
fi

if [ ! -d packet_forwarder ]; then
    git clone https://github.com/Lora-net/packet_forwarder.git
else
    pushd packet_forwarder
    git pull
    popd
fi

if [ "$1" = "create_img" ]; then
    ./install_for_img.sh
else
    ./install_normal.sh
fi

