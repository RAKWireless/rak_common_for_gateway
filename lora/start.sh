#!/bin/bash

# ------------------------------------------------------------
# Universal start.sh with Pi 3/4/5 support and inline reset
# ------------------------------------------------------------

# -------- BOARD DETECTION --------
# You can also use `cat /proc/device-tree/model` to detect
MODEL=$(tr -d '\0' < /proc/device-tree/model)
echo "[INFO] Detected board: $MODEL"

# -------- DEFAULT CONFIG --------
APP_PATH="./lora_pkt_fwd"
SET_EUI_SCRIPT="./set_eui.sh"
UPDATE_GWID_SCRIPT="./update_gwid.sh"
LOCAL_CONF="./local_conf.json"

# -------- GPIO & CHIP ADJUSTMENT BASED ON BOARD --------
if echo "$MODEL" | grep -q "Raspberry Pi 5"; then
    RESET_GPIO=17  # Example for Pi5, adjust based on your HAT/RAK concentrator
    GPIO_CHIP="gpiochip4"  # RP1 GPIO chip usually exposed as gpiochip4
    echo "[INFO] Pi 5 detected: Using GPIO $RESET_GPIO on $GPIO_CHIP"
else
    RESET_GPIO=17  # Default for Pi4 and earlier
    GPIO_CHIP="gpiochip0"
    echo "[INFO] Pi 4 or earlier detected: Using GPIO $RESET_GPIO on $GPIO_CHIP"
fi

# -------- RESET SEQUENCE --------
if command -v gpioset &> /dev/null; then
    echo "[INFO] Using GPIOD (gpioset) for reset"

    gpioset ${GPIO_CHIP} ${RESET_GPIO}=0
    sleep 0.1
    gpioset ${GPIO_CHIP} ${RESET_GPIO}=1
    sleep 0.1
    gpioset ${GPIO_CHIP} ${RESET_GPIO}=0
    sleep 0.1

else
    echo "[INFO] Using Sysfs GPIO for reset"

    GPIO_PATH="/sys/class/gpio/gpio${RESET_GPIO}"

    if [ ! -d "$GPIO_PATH" ]; then
        echo $RESET_GPIO > /sys/class/gpio/export
        sleep 0.1
    fi

    echo "out" > ${GPIO_PATH}/direction
    echo 0 > ${GPIO_PATH}/value
    sleep 0.1
    echo 1 > ${GPIO_PATH}/value
    sleep 0.1
    echo 0 > ${GPIO_PATH}/value
    sleep 0.1

    echo $RESET_GPIO > /sys/class/gpio/unexport
fi

echo "[INFO] Reset sequence completed"

# -------- Set EUI --------
if [ -x "$SET_EUI_SCRIPT" ]; then
    echo "[INFO] Running set_eui.sh..."
    $SET_EUI_SCRIPT
    sleep 0.2
else
    echo "[WARNING] set_eui.sh not found or not executable"
fi

# -------- Optional GWID update (uncomment to enable) --------
# if [ -x "$UPDATE_GWID_SCRIPT" ]; then
#     echo "[INFO] Running update_gwid.sh..."
#     $UPDATE_GWID_SCRIPT $LOCAL_CONF
# fi

sleep 0.5

# -------- Start packet forwarder --------
if [ ! -x "$APP_PATH" ]; then
    echo "[ERROR] Packet forwarder not found or not executable: $APP_PATH"
    exit 1
fi

echo "[INFO] Starting packet forwarder..."
$APP_PATH

if [ $? -eq 0 ]; then
    echo "[INFO] Packet forwarder exited normally."
else
    echo "[ERROR] Packet forwarder exited with error."
fi

exit 0
