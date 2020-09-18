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

print_help()
{
    echo "--help                Print help info."
    echo ""
    echo "--chirpstack=[install/not_install]"
    echo "                      Chirpstack, default value is install"
    echo ""
    exit
}

rpi_model=`do_get_rpi_model`

ARGS=`getopt -o "" -l "help,img,chirpstack:" -- "$@"`

eval set -- "${ARGS}"

INSTALL_CHIRPSTACK=1

CREATE_IMG=""

while true; do
    case "${1}" in
        --help)
        shift;
        print_help
        ;;

        --img)
        shift;
        CREATE_IMG=create_img
        ;;

        --chirpstack)
        shift;
        if [[ -n "${1}" ]]; then
            if [ "not_install" = "${1}" ]; then
                INSTALL_CHIRPSTACK=0
            elif [ "install" = "${1}" ]; then
                INSTALL_CHIRPSTACK=1
            else
                echo "invalid value"
                exit
            fi

            if [ $rpi_model -ne 3 ] && [ $rpi_model -ne 4 ]; then
                INSTALL_CHIRPSTACK=0
            fi
            shift;
        fi
        ;;

        --)
        shift;
#        echo "Invalid para.1"
        break;
        ;;
#        *) 
#		echo "Invalid para.2"; break ;;
    esac
done

# select gw model
./choose_model.sh $CREATE_IMG

apt update
pushd rak
./install.sh $CREATE_IMG
sleep 1
popd
set +e
write_json_chirpstack_install $INSTALL_CHIRPSTACK
set -e

pushd ap
./install.sh $CREATE_IMG
sleep 1
popd

if [ "$INSTALL_CHIRPSTACK" = 1 ]; then
    pushd chirpstack
    ./install.sh $CREATE_IMG
    sleep 1
    popd
fi

pushd lte
./install.sh $CREATE_IMG
sleep 1
popd

pushd lora
./install.sh $CREATE_IMG
sleep 1
popd
if [ "$CREATE_IMG" = "create_img" ]; then
    pushd /usr/local/rak
    mv bin bin_bak
    popd
fi

pushd sysconf
./install.sh $CREATE_IMG
sleep 1
popd

echo_success "*********************************************************"
echo_success "*  The RAKwireless gateway is successfully installed!   *"
echo_success "*********************************************************"
