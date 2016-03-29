#ifndef __BL_CONFIG_H__
#define __BL_CONFIG_H__

/**
 * Baudrate for UART1.
 */
#define BAUD_RATE 57600

/**
 * Registers and pin number for RS485/UART direction.
 * Output -> high
 * Input  -> low
 *
 * This pin has pull-down resistor, thus default direction is input.
 */
#define UART_DIR_PORT PORTD
#define UART_DIR_DDR  DDRD
#define UART_DIR_PIN  PD2

/**
 * Modbus slave address of this device.
 * The full address is created from three GPIO pins and this constant.
 * If GPIO pins are set to 0x03 and this constant 0x80 the resulting address
 * will be 0x83.
 */
#define SLAVE_ADDRESS 0x80

/**
 * First received modbus message for this slave should be unlock message.
 * The modbus function is 0x10, register address is `UNLOCK_ADDRESS` and
 * message should contains 4 bytes (2 words) in big endian order.
 *
 * The unlock secret is constant 0xCA0693D8 (big endian). GCC assumes little
 * endian, so constant is 0xD89306CA.
 */
#define UNLOCK_SECRET  0xD89306CA
#define UNLOCK_ADDRESS 0xFFFF

/**
 * Debug informations printed to UART1.
 */
// #define DEBUG_MAIN
// #define DEBUG_MODBUS
// #define DEBUG_MODBUS_VERBOSE
// #define DEBUG_FLASH
// #define DEBUG_FLASH_VERBOSE


/*******************************************************************************
 ******************************************************************************/

// Aux macros. Do not change!

#define BAUD ((F_CPU/(BAUD_RATE*8L)-1)/2)
#define BAUD_DOUBLE ((F_CPU/(BAUD_RATE*8L))-1)

#ifdef __BYTE_ORDER__
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define HTONS(x) ((uint16_t) (((uint16_t) (x) << 8) | ((uint16_t) (x) >> 8)))
#define HTONL(x) ((uint32_t) (((uint32_t) HTONS(x) << 16) | HTONS((uint32_t) (x) >> 16)))
#elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#define HTONS(x) ((uint16_t) (x))
#define HTONL(x) ((uint32_t) (x))
#else
#error Byte order not supported!
#endif
#else
#error Byte order not defined!
#endif

// All our PROGMEM data is in the same extended range as the FLASHEND
#include <avr/pgmspace.h>
#if defined(__AVR_ATmega1284P__)
#define pgm_read_byte_progmem(ptr) pgm_read_byte_far((FLASHEND&0xFFFF0000)|(uint16_t)(ptr))
#elif defined(__AVR_ATmega328P__) || defined(__AVR_ATmega168P__) || defined(__AVR_ATmega168__) || defined(__AVR_ATmega88P__)
#define pgm_read_byte_progmem(ptr) pgm_read_byte((uint16_t)(ptr))
#endif

#define hex(digit) ((digit)+((digit)>9?'A'-10:'0'))

#endif
