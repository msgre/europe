/*******************************************************************************
 * Main firmware for Europe's gate board.
 * Implemented for ATMegaXX8P.
 *
 * Date: 10MAR2016
 * Author: Vlastimil Slintak <slintak@uart.cz>
 ******************************************************************************/

#include <inttypes.h>
#include <stdlib.h>
#include <avr/io.h>
#include <avr/wdt.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "config.h"
#include "rs485.h"
#include "modbus.h"
#include "timers.h"
#include "gpio.h"

#define MODBUS_REGISTERS 3
#define MODBUS_REG_INPUTS 0
#define MODBUS_REG_HWFW_VERSION 1
#define MODBUS_REG_RESET 2
static uint16_t modbus_registers[MODBUS_REGISTERS];
static uint8_t modbus_registers_change[MODBUS_REGISTERS];

int main(void) {
    wdt_reset();
    wdt_enable(WDTO_8S);

    // Set address pins as inputs.
    wdt_reset();
    MODBUS_ADDRESS_INIT();

    // Initialize RS485/UART interface.
    wdt_reset();
    rs485_init();

    // Initialize all IO from IR input and enable PCINT.
    wdt_reset();
    gpio_init();

    // Start milliseconds timer.
    wdt_reset();
    timer1_init();

    // Initialize modbus.
    uint8_t slave = MODBUS_ADDRESS_READ();
    modbus_init(slave, modbus_registers, modbus_registers_change, MODBUS_REGISTERS);

    // Write HW and FW versions into modbus register.
    modbus_registers[MODBUS_REG_HWFW_VERSION] = (HW_VERSION << 12) | (FW_VERSION);

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

    uint8_t tmp;
    while(1) {
        // Read actual input states.
        tmp = gpio_loop();
        if(tmp > 0) {
            modbus_registers[MODBUS_REG_INPUTS] = tmp;
        }
        // Main modbus loop.
        modbus_loop();

        // Reset
        if(modbus_registers_change[MODBUS_REG_RESET] == MODBUS_REGS_WRITE) {
            rs485_flush();
            wdt_reset();
            wdt_disable();
            wdt_enable(WDTO_500MS);
            while(1);
        }

        // Clear last input states if master read its Modbus register.
        if(modbus_registers_change[MODBUS_REG_INPUTS] == MODBUS_REGS_READ) {
            modbus_registers_change[MODBUS_REG_INPUTS] = 0;
            modbus_registers[MODBUS_REG_INPUTS] = 0;
        }

        wdt_reset();
    }


    while(1); // Code should not reach here!
    return 0;
}
