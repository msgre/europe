#include "timer.h"

void timer1_start(void) {
    TCCR1B = 0x00; /* Disable timer. */
    TIFR1 = 0xFF; /* Clear overflow flag. */
    TCNT1 = 0x0000; /* Set counter to zero. */
    TCCR1B = _BV(CS02); /* Enable timer, prescaler 256. */
}

void timer0_start(void) {
    TCCR0B = 0x00; /* Disable timer. */
    TCCR0A = 0x00; /* Normal opration mode */
    TIFR0 = 0xFF; /* Clear overflow flag. */
    TCNT0 = 0x00; /* Set counter to zero. */
    TCCR0B = _BV(CS02) | _BV(CS00); /* Enable timer, prescaler 1024. */
}