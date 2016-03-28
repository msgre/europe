#include <avr/interrupt.h>
#include <util/atomic.h>
#include "timers.h"

static volatile uint32_t timer1_millis = 0;

#define OCR_CONST ((F_CPU / 1) / 1000)

/**
 * Initialize 16bit timer1.
 * Prescaler is 1 -> 1 ms.
 */
void timer1_init(void) {
    TCCR1A = 0;
    TCCR1B = _BV(WGM12) | _BV(CS10); // CTC, prescaller 1
    TIMSK1 = _BV(OCIE1A); // Enable OCIE1A interrupt.
    OCR1A = OCR_CONST;
}

uint32_t timer1_get(void) {
    uint32_t ms;
    ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
        ms = timer1_millis;
    }
    return ms;
}

void timer1_reset(void) {
    ATOMIC_BLOCK(ATOMIC_RESTORESTATE) {
        timer1_millis = 0;
    }
}

ISR(TIMER1_COMPA_vect) {
    ++timer1_millis;
}

/**
  * Set 8b Timer2. Prescaler 256 @8MHz ~ 8.192ms, @16MHz ~ 4.096ms.
  */
void timer2_start(void) {
    TCCR2B = 0x00; /* Disable timer. */
    TCCR2A = 0x00; /* Normal opration mode */
    TIFR2 |= _BV(TOV2); /* Clear overflow flag. */
    TCNT2 = 0x00; /* Set counter to zero. */
    TCCR2B = _BV(CS22) | _BV(CS21); /* Enable timer, prescaler 256. */
}