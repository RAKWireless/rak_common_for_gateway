#!/bin/bash

# ------------------------------------------------------------
# Universal reset_lgw.sh - Auto-detects Pi2/4/5, GPIOD + Sysfs
# ------------------------------------------------------------

# -------- BOARD DETECTION --------
MODEL=$(tr -d '\0' < /proc/device-tree/model)
echo "[INFO] Detected board: $MODEL"

# -------- GPIO & CHIP CONFIG --------
if echo "$MODEL" | grep -q "Raspberry Pi 5"; then
    RESET_GPIO=17  # Example for Pi5 (adjust to match concentrator reset pin)
    GPIO_CHIP="gpiochip4"  # RP1 GPIO typically gpiochip4
    echo "[INFO] Pi 5 detected: Using GPIO $RESET_GPIO on $GPIO_CHIP"
else
    RESET_GPIO=17  # Default for Pi4 and earlier
    GPIO_CHIP="gpiochip0"
    echo "[INFO] Pi 4 or earlier detected: Using GPIO $RESET_GPIO on $GPIO_CHIP"
fi

# -------- RESET SEQUENCE --------
if command -v gpioset &> /dev/null; then
    echo "[INFO] Using GPIOD (gpioset) for reset"

    # Pull reset low -> high -> low (with delays)
    gpioset ${GPIO_CHIP} ${RESET_GPIO}=0
    sleep 0.1
    gpioset ${GPIO_CHIP} ${RESET_GPIO}=1
    sleep 0.1
    gpioset ${GPIO_CHIP} ${RESET_GPIO}=0
    sleep 0.1

else
    echo "[INFO] Using Sysfs GPIO for reset"

    GPIO_PATH="/sys/class/gpio/gpio${RESET_GPIO}"

    # Export GPIO if not already exported
    if [ ! -d "$GPIO_PATH" ]; then
        echo $RESET_GPIO > /sys/class/gpio/export
        sleep 0.1
    fi

    # Set direction and perform reset
    echo "out" > ${GPIO_PATH}/direction
    echo 0 > ${GPIO_PATH}/value
    sleep 0.1
    echo 1 > ${GPIO_PATH}/value
    sleep 0.1
    echo 0 > ${GPIO_PATH}/value
    sleep 0.1

    # Optional: unexport to release GPIO
    echo $RESET_GPIO > /sys/class/gpio/unexport
fi

echo "[INFO] Reset sequence completed."
exit 0
