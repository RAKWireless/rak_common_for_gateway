# rak_common_for_gateway

##	Introduction 

The aim of this project is to help users set up a LoRa network easily. The User Guide can be get from our Web.

##	Supported platforms

This project currently provides support for the below platforms.
* RAK831
* RAK833
* RAK2245
* RAK2247
* RAK7243

##	Changelog
2019-09-19 V4.0.0
* Use lan0's mac address when eth0 does not exist.

2019-05-24 V2.9

* 1.Multiple models are integrated with one common version.
* 2.Upgrade LoRa server to 3.0.

##	Installation procedure

step1 : Download and install [Raspbian Stretch LITE](https://www.raspberrypi.org/downloads/raspbian/) 

step2 : Use "sudo raspi-config" command, enable spi and i2c interface.

step3 : Clone the installer and start the installation.

      $ sudo apt update; sudo apt install git -y
      $ git clone https://github.com/RAKWireless/rak_common_for_gateway.git ~/rak_common_for_gateway
      $ cd ~/rak_common_for_gateway
      $ sudo ./install.sh

step4 : Next you will see some messages as follow. Please select the corresponding hardware model.

      Please select your gateway model:
      *	1.RAK831
      *	2.RAK833
      *	3.RAK2245
      *	4.RAK2247
      *	5.RAK7243
      Please enter 1-5 to select the model:

step5 : Wait a moment and the installation is complete.If your gateway uses a wired connection, please reconfigure the LAN's IP address using "sudo gateway-config" after the installation is complete.

step6 : For more other features, please use "sudo gateway-config".
