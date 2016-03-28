/*******************************************************************************
 * Neopixel firmware for Europe's gate board.
 * Implemented for ATMegaXX8P.
 *
 * The WS2812 functions are modified https://github.com/cpldcpu/light_ws2812
 *
 * Date: 28MAR2016
 * Author: Vlastimil Slintak <slintak@uart.cz>
 ******************************************************************************/

#include <inttypes.h>
#include <stdlib.h>
#include <string.h>
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "config.h"
#include "rs485.h"
#include "modbus.h"
#include "timers.h"
#include "gpio.h"
#include "ws2812.h"

#define MODBUS_BASIC_REGISTERS 3
#define MODBUS_REG_INPUTS 0
#define MODBUS_REG_HWFW_VERSION 1
#define MODBUS_REG_RESET 2
static uint16_t mb_basic_registers[MODBUS_BASIC_REGISTERS];
static uint8_t mb_basic_registers_change[MODBUS_BASIC_REGISTERS];

static uint16_t mb_ws2812_registers[WS2812_NUM];
static uint8_t mb_ws2812_registers_change[WS2812_NUM];

#define MB_ADDRESS_REGIONS 2
static mb_registers_t mb_registers[] = {
    // Basic registers -- inputs, version, reset.
    {0x0000, MODBUS_BASIC_REGISTERS, mb_basic_registers, mb_basic_registers_change},
    // WS2812 LEDs -- color, brightness.
    {0x1000, WS2812_NUM, mb_ws2812_registers, mb_ws2812_registers_change}
};

static uint8_t leds_update;
struct cRGB leds[WS2812_NUM];

int main(void) {
    wdt_reset();
    wdt_enable(WDTO_8S);

    // Set address pins as inputs.
    wdt_reset();
    MODBUS_ADDRESS_INIT();

    // Initialize RS485/UART interface.
    wdt_reset();
    rs485_init();

    // Initialize WS2812 (Neopixel). Turn off all LEDs.
    wdt_reset();
    memset((uint8_t *)leds, 0, sizeof(leds));
    ws2812_setleds(leds, WS2812_NUM);
    leds_update = 0;

    // Start milliseconds timer.
    wdt_reset();
    timer1_init();

    // Initialize modbus.
    uint8_t slave = MODBUS_ADDRESS_READ();
    modbus_init(slave, mb_registers, MB_ADDRESS_REGIONS);

    // Write HW and FW versions into modbus register.
    mb_basic_registers[MODBUS_REG_HWFW_VERSION] = (HW_VERSION << 12) | (FW_VERSION);

    // Blink onboard LED.
    wdt_reset();
    LED_INIT();
    for(uint8_t i = 0; i < LED_RESTART_BLINK; i++) {
        LED_ON();
        _delay_ms(10);
        LED_OFF();
        _delay_ms(50);
    }

    // Enable interrupts.
    sei();

    #ifdef DEBUG_MAIN
    rs485_putp(PSTR("Modbus addr: 0x"));
    rs485_puthex2(slave);
    rs485_putp(PSTR("\nUp and running.\n"));
    #endif

    while(1) {
        // Main modbus loop.
        modbus_loop();

        // Reset
        if(mb_basic_registers_change[MODBUS_REG_RESET] == MODBUS_REGS_WRITE) {
            rs485_flush();
            wdt_reset();
            wdt_disable();
            wdt_enable(WDTO_500MS);
            while(1);
        }

        // Check if any LED settings changed. If so, send it to WS2812.
        for(uint8_t i = 0; i < WS2812_NUM; i++) {
            if(mb_ws2812_registers_change[i] == MODBUS_REGS_WRITE) {
                mb_ws2812_registers_change[i] = MODBUS_REGS_NOT_CHANGED;

                // One Modbus register contains RGB and brightness (L).
                // Register is 0xLRGB, modbus has different endianess than AVR,
                // thus our data have format - 0xGBLR.
                uint8_t brightness = ((mb_ws2812_registers[i] >> 4) & 0x0F) + 1;
                leds[i].r = ((mb_ws2812_registers[i] >> 0) & 0x0F) * brightness;
                leds[i].g = ((mb_ws2812_registers[i] >> 12) & 0x0F) * brightness;
                leds[i].b = ((mb_ws2812_registers[i] >> 8) & 0x0F) * brightness;
                leds_update = 1;
                LED_ON();
            }
        }

        // If any LED changed, send new data to WS2812.
        if(leds_update) {
            ws2812_sendarray((uint8_t *)leds, WS2812_NUM*3);
            leds_update = 0;
            LED_OFF();
        }

        wdt_reset();
    }

    while(1); // Code should not reach here!
    return 0;
}
