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
* RAK5146(SPI)
* RAK5146(SPI) with LTE



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
      *	 11.RAK5146 SPI
      *	 12.RAK5146 SPI with LTE
      Please enter 1-12 to select the model:

step5 : Wait a moment and the installation is complete.

step6 : reboot your gateway.

step7 : Now you can use "sudo gateway-config" to configure your gateway.


##	Docker

If you want to build or use docker image, you can access https://github.com/RAKWireless/udp-packet-forwarder repository.
