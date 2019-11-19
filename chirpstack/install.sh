#!/bin/bash

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh
source $SCRIPT_COMMON_FILE

# script needs to be run with super privilege
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run with superuser privilege. Try 'sudo ./install.sh'\n"
  exit 1
fi

rpi_model=`do_get_rpi_model`
if [ $rpi_model -ne 3 ] && [ $rpi_model -ne 4 ]; then
    echo_warn "ChirpStack is not support for this rpi model."
    exit 0
fi



# Try to get gateway ID from MAC address
# First try eth0, if that does not exist, try wlan0 (for RPi Zero)
GATEWAY_EUI_NIC="eth0"
if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
    GATEWAY_EUI_NIC="wlan0"
fi

if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
    GATEWAY_EUI_NIC="usb0"
fi

if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
    echo "ERROR: No network interface found. Cannot set gateway ID."
    exit 1
fi

GATEWAY_EUI=$(ip link show $GATEWAY_EUI_NIC | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
GATEWAY_EUI=${GATEWAY_EUI^^}


cp init_sql.sql /tmp/init_sql.sql -f
if [ "$1" = "create_img" ]; then
    echo ""
else
    sed  -i "s/0000000000088888/$GATEWAY_EUI/g"  /tmp/init_sql.sql
fi



apt list --upgradable

# 1. install requirements
apt -f -y install dialog mosquitto mosquitto-clients redis-server redis-tools postgresql

# 2. setup PostgreSQL databases and users
sudo -u postgres psql -c "create role chirpstack_as with login password 'dbpassword';"
sudo -u postgres psql -c "create role chirpstack_ns with login password 'dbpassword';"
sudo -u postgres psql -c "create database chirpstack_as with owner chirpstack_as;"
sudo -u postgres psql -c "create database chirpstack_ns with owner chirpstack_ns;"
sudo -u postgres psql chirpstack_as -c "create extension pg_trgm;"
sudo -u postgres psql chirpstack_as -c "create extension hstore;"
sudo -u postgres psql -U postgres -f /tmp/init_sql.sql
rm -f /tmp/init_sql.sql

#3. install lora packages
#3.1 install https requirements
#apt -f -y install apt-transport-https dirmngr
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1CE2AFD36DBCCA00
#sudo echo "deb https://artifacts.chirpstack.io/packages/3.x/deb stable main" | sudo tee /etc/apt/sources.list.d/chirpstack.list
#apt update
#apt install chirpstack-network-server
#apt install chirpstack-gateway-bridge
#apt install chirpstack-application-server

#3.2 download chirpstack packages
wget https://artifacts.chirpstack.io/packages/3.x/deb/pool/main/c/chirpstack-application-server/chirpstack-application-server_3.5.1_linux_armv7.deb
wget https://artifacts.chirpstack.io/packages/3.x/deb/pool/main/c/chirpstack-gateway-bridge/chirpstack-gateway-bridge_3.4.1_linux_armv7.deb
wget https://artifacts.chirpstack.io/packages/3.x/deb/pool/main/c/chirpstack-network-server/chirpstack-network-server_3.4.1_linux_armv7.deb

#3.3 install chirpstack packages
dpkg -i chirpstack-application-server_3.5.1_linux_armv7.deb
dpkg -i chirpstack-gateway-bridge_3.4.1_linux_armv7.deb
dpkg -i chirpstack-network-server_3.4.1_linux_armv7.deb

#4. configure lora
# configure chirpstack Server
#cp -f /etc/chirpstack-network-server/chirpstack-network-server.toml  /etc/chirpstack-network-server/chirpstack-network-server.toml_bak
cp -rf ./chirpstack-network-server_conf/*  /etc/chirpstack-network-server/
chown -R networkserver:networkserver /etc/chirpstack-network-server

# configure chirpstack App Server
#cp -f /etc/chirpstack-application-server/chirpstack-application-server.toml /etc/chirpstack-application-server/chirpstack-application-server.toml_bak
cp -f ./chirpstack-application-server.toml /etc/chirpstack-application-server/chirpstack-application-server.toml
chown -R appserver:appserver /etc/chirpstack-application-server

# start chirpstack-network-server
systemctl restart chirpstack-network-server

# start chirpstack-application-server
systemctl restart chirpstack-application-server

# start chirpstack-gateway-bridge
systemctl restart chirpstack-gateway-bridge
echo_success "Install ChirpStack success!"
