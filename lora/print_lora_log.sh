#!/bin/bash
cd /opt/ttn-gateway/lora_gateway/util_pkt_logger

cp /opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/*.json .

rm *.csv -rf

./util_pkt_logger &

sleep 5

log_filename=`find ./ -name "*.csv" -type f`

echo "------------------------log file name: ${log_filename}-----------------"
echo "---------------------------log------------------------------"
tail -n 100 -f ${log_filename} 
