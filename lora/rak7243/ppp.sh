#!/bin/bash

while [ true=true  ]
do
#    echo aaa
    line=`ifconfig | grep ppp0 -c`
#    echo $line

    if [ $line -ne 0 ]; then
#        echo "111"
        route del default
        route add default dev ppp0
        exit
    fi
    sleep 30
done
