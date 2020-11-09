#! /bin/bash
GATEWAY_EUI=""
if [ ! -e "/opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/local_conf.json" ]; then
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
	LOCAL_CONFIG_FILE=/opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/local_conf.json
	echo -e "{\n\t\"gateway_conf\": {\n\t\t\"gateway_ID\": \"$GATEWAY_EUI\" \n\t}\n}" >$LOCAL_CONFIG_FILE
	echo "$GATEWAY_EUI"
fi
