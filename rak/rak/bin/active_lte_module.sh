#!/bin/sh

cd /sys/class/gpio/
echo 5 > export
echo 6 > export
echo 13 > export
echo 19 > export
echo 21 > export
echo 26 > export
echo out > gpio5/direction
echo out > gpio6/direction
echo out > gpio13/direction
echo out > gpio19/direction
echo in > gpio21/direction
echo out > gpio26/direction

echo 0 > gpio5/value
echo 0 > gpio6/value
echo 0 > gpio13/value
echo 0 > gpio19/value
echo 0 > gpio26/value


#
cd /sys/class/gpio/

echo "18" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio18/direction
echo 0 > /sys/class/gpio/gpio18/value
sleep 0.2
echo 1 > /sys/class/gpio/gpio18/value
sleep 0.2
echo 0 > /sys/class/gpio/gpio18/value

