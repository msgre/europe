#include <stdint.h>
#include <avr/io.h>
#include <avr/interrupt.h>

#include "config.h"
#include "rs485.h"
#include "timers.h"
#include "gpio.h"

static uint8_t gpio_new_state;
static uint32_t gpio_new_state_time;

static uint8_t gpio_tmp = 0;
static uint32_t gpio_now = 0;

/**
 * Pin change interrupt 1 (for PCINT8 - PCINT13).
 */
ISR(PCINT1_vect) {
    // Gates are active low.
    gpio_new_state = ~IR_PIN & IR_ALL;
    gpio_new_state_time = timer1_get();
    PCINT_DISABLE();
}

 void gpio_init(void) {
    // Enable interrupt 1 for pin change.
    PCINT_ENABLE();
    // Enable interrupt for each pin.
    PCMSK1 |= _BV(PCINT8) | _BV(PCINT9) | _BV(PCINT10);
    PCMSK1 |= _BV(PCINT11) | _BV(PCINT12) | _BV(PCINT13);

    // Set PC0-PC5 as inputs.
    IR_INIT();

    gpio_new_state = 0;
    gpio_new_state_time = 0;
 }

uint8_t gpio_loop(void) {
    gpio_now = timer1_get();
    if((gpio_now - gpio_new_state_time) > IR_DEBOUNCE_TIME) {
        // Re-enable PCINT from IR inputs after some "debounce" time.
        PCINT_ENABLE();
        gpio_tmp = 0;
        LED_OFF();
    } else {
        gpio_tmp = gpio_new_state;
        if(gpio_tmp) {
            #ifdef DEBUG_MAIN
            rs485_puthex4(gpio_now);
            rs485_putp(PSTR(": GPIO "));
            rs485_puthex2(gpio_tmp);
            rs485_putc('\n');
            #endif

            LED_ON();
            gpio_new_state = 0;
        }
    }

    return gpio_tmp;
}