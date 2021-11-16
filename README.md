# rak_common_for_gateway

##	Introduction 

The aim of this project is to help users to use the RAK Raspberry Pi Developer Gateway more easily. The User Guide can be get from our Web(https://docs.rakwireless.com/Introduction/).

##	Supported platforms

This project currently provides support for the below platforms.
* RAK831(Choose RAK2245)
* RAK2245
* RAK7243/RAK7244 no LTE
* RAK7243/RAK7244 with LTE
* RAK833(USB)(Choose RAK2247 USB)
* RAK2247(USB)
* RAK833(SPI)(Choose RAK2247 SPI)
* RAK2247(SPI)
* RAK2246
* RAK7248 no LTE (RAK2287 + raspberry pi)
* RAK7248 with LTE (RAK2287 + LTE + raspberry pi)
* RAK2287(USB)
* RAK7271(Choose RAK2287 USB)
* RAK5146(USB)
* RAK7371(Choose RAK5146 USB)

##	Changelog
2021-06-03 V4.2.9

* 1.Added support for RAK5146-USB and change its sx1302_hal  version from V2.0.1 to V2.1.0.

2021-03-09 V4.2.8

* 1.Added support for RAK2287-USB.
* 2.Remove some obsolete models.

2021-01-21 V4.2.7

* 1.Only upgraded for RAK2287, added EU433 and CN470 for RAK2287.

2020-11-25 V4.2.6

* 1.Added support for RAK7248C.
* 2.Added support for class B in global_conf.json, but it is disabled by default. When needed, you can enable it in `/opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/global_conf.json`.

2020-09-01 V4.2.5

* 1.Add AS920_923.
* 2.EU433 changed to 8 consecutive channels.

2020-07-20 V4.2.4

* 1.Add other region global_conf.json for RAK2287.
* 2.Modify sx1302 tx power param.
* 3.Add RAK2285 support.

2020-07-09 V4.2.3

* 1.Some naming changes.

2020-06-28 V4.2.2

* 1.Fix a display issue with gateway-config.
* 2.Delete the temperature printing of RAK2287.

2020-05-02 V4.2.1

* 1.Added support for RAK2287 spi version.

2020-02-14 V4.2.0

* 1.Added support for RAK2246 spi version.
* 2.Fix the bug that the internet cannot be accessed after ppp0 redial.
* 3.install.sh can pass --help parameter to see more installation information.
* 4.Install the latest version of chirpstack by default.
* 5.gateway-version print more information.
* 6.gateway-config and gateway-version show the actual gateway_id.
* 7.Create a rak_ap file in the /boot directory to restore to ap mode.
* 8.Modify the global_conf.json file of 7246 to make the transmit power more accurate.
* 9.When there is no match for tx power, the nearest smaller power will be used.[Semtech UDP (legacy) packet forwarder](https://github.com/Lora-net/packet_forwarder/blob/master/lora_pkt_fwd/src/lora_pkt_fwd.c#L2517-L2527) 
* 10.Delete default DNS(8.8.8.8, 223.5.5.5), the gateway will use the DNS assigned by the router to which it is connected.
* 11.In case of GPS connection, automatically change the system time to GPS time.

2019-12-17 V4.1.1
* Added support for rak2247/rak833 spi version.

2019-12-02
* Fix a bug. There is a mistake word "diable" in rak/gateway-config script, line 272, it should be do_ChirpStack disable.

2019-11-19 V4.1.0
* 1.LoRaServer changed its name to ChirpStack.
* 2.ChirpStack turns off ADR by default.
* 3.Unconfigure the ip of eth0 to 192.168.10.10.
* 4.Users can change the gateway_id in local_conf.json.
* 5.Increase i2c rate for rak7243.
* 6.Install chirpstack only on Raspberry Pi 3 and Raspberry Pi 4. Pi zero can't run ChirpStack.
* 7.In the AP mode, the gateway IP address is 192.168.230.1.

2019-09-19 V4.0.0
* Use lan0's mac address when eth0 does not exist.

2019-05-24 V2.9

* 1.Multiple models are integrated with one common version.
* 2.Upgrade LoRa server to 3.0.

##	Installation procedure

step1 : Download and install latest [Raspberry Pi OS Lite](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit) 

step2 : Use "sudo raspi-config" command, enable spi and i2c interface, disable login shell over serial and enable serial port hardware.

step3 : Clone the installer and start the installation (More installation options can be found in "sudo ./install.sh --help").

      $ sudo apt update; sudo apt install git -y
      $ git clone https://github.com/RAKWireless/rak_common_for_gateway.git ~/rak_common_for_gateway
      $ cd ~/rak_common_for_gateway
      $ sudo ./install.sh

step4 : Next you will see some messages as follow. Please select the corresponding hardware model.

      Please select your gateway model:
      *	 1.RAK2245
      *	 2.RAK7243/RAK7244 no LTE
      *	 3.RAK7243/RAK7244 with LTE
      *	 4.RAK2247(USB)
      *	 5.RAK2247(SPI)
      *	 6.RAK2246
      *	 7.RAK7248 no LTE (RAK2287 SPI + raspberry pi)
      *	 8.RAK7248 with LTE (RAK2287 SPI + LTE + raspberry pi)
      *	 9.RAK2287 USB
      *	 10.RAK5146 USB
      Please enter 1-10 to select the model:

step5 : Wait a moment and the installation is complete.

step6 : reboot your gateway.

step7 : Now you can use "sudo gateway-config" to configure your gateway.

