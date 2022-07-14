/*
 / _____)             _              | |
( (____  _____ ____ _| |_ _____  ____| |__
 \____ \| ___ |    (_   _) ___ |/ ___)  _ \
 _____) ) ____| | | || |_| ____( (___| | | |
(______/|_____)_|_|_| \__)_____)\____)_| |_|
  (C)2019 Semtech

Description:
    Functions used to handle LoRa concentrator SX1250 radios.

License: Revised BSD License, see LICENSE.TXT file include in the project
*/


/* -------------------------------------------------------------------------- */
/* --- DEPENDANCIES --------------------------------------------------------- */

#include <stdint.h>     /* C99 types */
#include <stdio.h>      /* printf fprintf */
#include <string.h>     /* memcmp */

#include "loragw_aux.h"
#include "loragw_mcu.h"
#include "sx1250_usb.h"

/* -------------------------------------------------------------------------- */
/* --- PRIVATE MACROS ------------------------------------------------------- */

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
#if DEBUG_RAD == 1
    #define DEBUG_MSG(str)                fprintf(stdout, str)
    #define DEBUG_PRINTF(fmt, args...)    fprintf(stdout,"%s:%d: "fmt, __FUNCTION__, __LINE__, args)
    #define CHECK_NULL(a)                if(a==NULL){fprintf(stderr,"%s:%d: ERROR: NULL POINTER AS ARGUMENT\n", __FUNCTION__, __LINE__);return -1;}
#else
    #define DEBUG_MSG(str)
    #define DEBUG_PRINTF(fmt, args...)
    #define CHECK_NULL(a)                if(a==NULL){return -1;}
#endif

/* -------------------------------------------------------------------------- */
/* --- PRIVATE TYPES -------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/* --- PRIVATE CONSTANTS ---------------------------------------------------- */

#define READ_ACCESS     0x00
#define WRITE_ACCESS    0x80

/* -------------------------------------------------------------------------- */
/* --- PRIVATE VARIABLES ---------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/* --- PRIVATE FUNCTIONS ---------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/* --- PUBLIC FUNCTIONS DEFINITION ------------------------------------------ */

int sx125x_usb_r(void *com_target, uint8_t spi_mux_target, uint8_t address, uint8_t *data) {
    int usb_device;
    int size = 1;
    uint8_t command_size = size + 7; /* 5 bytes: REQ metadata, 2 bytes: RAW SPI frame */
    uint8_t in_out_buf[command_size];
    int a;

    /* check input variables */
    CHECK_NULL(com_target);
    CHECK_NULL(data);

    usb_device = *(int *)com_target;

    /* prepare command */
    /* Request metadata */
    in_out_buf[0] = 0; /* Req ID */
    in_out_buf[1] = MCU_SPI_REQ_TYPE_READ_WRITE; /* Req type */
    in_out_buf[2] = MCU_SPI_TARGET_SX1302; /* MCU -> SX1302 */
    in_out_buf[3] = (uint8_t)((size + 2) >> 8); /* payload size + spi_mux_target + op_code */
    in_out_buf[4] = (uint8_t)((size + 2) >> 0); /* payload size + spi_mux_target + op_code */
    /* RAW SPI frame */
    in_out_buf[5] = spi_mux_target; /* SX1302 -> RADIO_A or RADIO_B */
    in_out_buf[6] = READ_ACCESS | (address & 0x7F);
    in_out_buf[7] = 0x00;

    a = mcu_spi_write(usb_device, in_out_buf, command_size);

    /* determine return code */
    if (a != 0) {
        DEBUG_MSG("ERROR: USB SX125X READ FAILURE\n");
        return -1;
    } else {
        DEBUG_PRINTF("Note: USB SX125X read success: %02X\n", in_out_buf[7]);
        *data = in_out_buf[7];
        return 0;
    }
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

int sx125x_usb_w(void *com_target, uint8_t spi_mux_target, uint8_t address, uint8_t data) {
    int usb_device;
    int size = 1;
    uint8_t command_size = size + 7; /* 5 bytes: REQ metadata, 2 bytes: RAW SPI frame */
    uint8_t in_out_buf[command_size];
    int a;

    /* check input variables */
    CHECK_NULL(com_target);

    usb_device = *(int *)com_target;

    /* prepare command */
    /* Request metadata */
    in_out_buf[0] = 0; /* Req ID */
    in_out_buf[1] = MCU_SPI_REQ_TYPE_READ_WRITE; /* Req type */
    in_out_buf[2] = MCU_SPI_TARGET_SX1302; /* MCU -> SX1302 */
    in_out_buf[3] = (uint8_t)((size + 2) >> 8); /* payload size + spi_mux_target + op_code */
    in_out_buf[4] = (uint8_t)((size + 2) >> 0); /* payload size + spi_mux_target + op_code */
    /* RAW SPI frame */
    in_out_buf[5] = spi_mux_target; /* SX1302 -> RADIO_A or RADIO_B */
    in_out_buf[6] = WRITE_ACCESS | (address & 0x7F);
    in_out_buf[7] = data;

    a = mcu_spi_write(usb_device, in_out_buf, command_size);

    /* determine return code */
    if (a != 0) {
        DEBUG_MSG("ERROR: USB SX125X WRITE FAILURE\n");
        return -1;
    } else {
        DEBUG_MSG("Note: USB SX125X write success\n");
        return 0;
    }
}

/* --- EOF ------------------------------------------------------------------ */