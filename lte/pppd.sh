#!/bin/bash

killall -9 ppp.sh
/usr/local/rak/bin/ppp.sh &
pppd call gprs

