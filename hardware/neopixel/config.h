#ifndef __IR_CONFIG_H__
#define __IR_CONFIG_H__

#define FW_VERSION 0x010UL
#define HW_VERSION 0x1UL

/******************************************************************************/
/** RS485 config **************************************************************/

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
#define RS485_DIR_PORT PORTD
#define RS485_DIR_DDR  DDRD
#define RS485_DIR_PIN  PD2

/**
 * RX buffer size for RS485 (UART).
 * In bytes.
 */
#define RS485_BUFFER_SIZE 128

/******************************************************************************/
/** LED config ****************************************************************/

/**
 * How many times should LED blink after the restart.
 */
#define LED_RESTART_BLINK 3

/**
 * Number of WS2812 (Neopixel) LEDs.
 */
#define WS2812_NUM 24

/**
 * Data port where WS2812 are connected.
 */
#define WS2812_PORT D

/**
 * Pin number with WS2812.
 */
#define WS2812_PIN  6

/******************************************************************************/
/** Debug output **************************************************************/

/**
 * Debug informations printed to UART0.
 */
// #define DEBUG_MAIN
// #define DEBUG_IR
// #define DEBUG_MODBUS
// #define DEBUG_MODBUS_VERBOSE

/******************************************************************************/
/** Aux macros. Do not change! ************************************************/

// All our PROGMEM data is in the same extended range as the FLASHEND
#include <avr/pgmspace.h>
#if defined(__AVR_ATmega1284P__)
#define pgm_read_byte_progmem(ptr) pgm_read_byte_far((FLASHEND&0xFFFF0000)|(uint16_t)(ptr))
#elif defined(__AVR_ATmega328P__) || defined(__AVR_ATmega168P__) || defined(__AVR_ATmega88P__)
#define pgm_read_byte_progmem(ptr) pgm_read_byte((uint16_t)(ptr))
#endif

#define hex(digit) ((digit)+((digit)>9?'A'-10:'0'))

#define MAX(x, y) (((x) > (y)) ? (x) : (y))
#define MIN(x, y) (((x) < (y)) ? (x) : (y))

#define BAUD ((F_CPU/(BAUD_RATE*8L)-1)/2)
#define BAUD_DOUBLE ((F_CPU/(BAUD_RATE*8L))-1)

#endif