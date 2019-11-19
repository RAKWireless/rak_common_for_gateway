#!/bin/bash

# Stop on the first sign of trouble
set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi

#$1=create_img

SCRIPT_COMMON_FILE=$(pwd)/rak/rak/shell_script/rak_common.sh
source $SCRIPT_COMMON_FILE

# select gw model
./choose_model.sh $1

apt update
pushd rak
./install.sh $1
sleep 1
popd

pushd ap
./install.sh $1
sleep 1
popd

pushd sysconf
./install.sh $1
sleep 1
popd

pushd chirpstack
./install.sh $1
sleep 1
popd

#pushd lorawan
#./install.sh
#sleep 1
#popd

pushd lte
./install.sh $1
sleep 1
popd

pushd lora
./install.sh $1
sleep 1

echo_success "*********************************************************"
echo_success "*  The RAKwireless gateway is successfully installed!   *"
echo_success "*********************************************************"
