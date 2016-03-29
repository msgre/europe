#include <inttypes.h>
#include <avr/io.h>
#include <avr/boot.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <avr/wdt.h>
#include <util/delay.h>
#include <stdlib.h>
#include <util/crc16.h>

#include "rs485.h"
#include "modbus.h"
#include "flash.h"
#include "timer.h"
#include "config.h"

#define LED_BLE _BV(PB5)
#define LED_INIT() DDRB |= (LED_BLE); \
                    PORTB &= ~(LED_BLE)
#define LED_ON()  PORTB |= (LED_BLE)
#define LED_OFF() PORTB &= ~(LED_BLE)

/**
 * Modbus slave address is defined by solder jumpers on DSP.
 * Initialize those pins as inputs with enabled pull-ups.
 */
#define MODBUS_ADDRESS_INIT() DDRD &= ~_BV(PD7); DDRB &= ~(_BV(PB0) | _BV(PB1) | _BV(PB2)); \
                              PORTD |= _BV(PD7); PORTB |= _BV(PB0) | _BV(PB1) | _BV(PB2)
#define MODBUS_ADDRESS_READ() ( ((PIND & _BV(PD7)) >> 7) | ((PINB & (_BV(PB0) | _BV(PB1) | _BV(PB2))) << 1) )
/**
 * MCU status register. ATMega1284P:
 *   0x01 = Power-on reset
 *   0x02 = External reset
 *   0x04 = Brown-out reset
 *   0x08 = Watchdog reset
 *   0x10 = JTAG reset
 */
static uint8_t mcusr;

static modbus_pdu_t pdu;

static uint8_t spm_buffer[SPM_PAGESIZE];
static uint32_t spm_address = 0x00000000;

void init(void) __attribute__((naked)) __attribute__((section(".init3")));
int main(void) __attribute__ ((section (".init9"))) __attribute__ ((used));

/**
 * Run firmware from address 0x0000. If this address does not contains
 * valid reset vector (non zero address), restart this bootloader.
 */
inline void start_app(void) {
    LED_OFF();
    wdt_reset();
    wdt_disable();
    if(FLASH_CHECK_APP()) {
        // asm volatile("jmp 0");
        ((void (*)())0x0)();
    } else {
        asm volatile("ijmp" :: "z" (NRWW_START/2));
    }
}

void download_fw(void) {
    #ifdef DEBUG_MAIN
    rs485_output();
    rs485_putp(PSTR("Download FW\n"));
    rs485_input();
    #endif

    timer1_start();
    while(!timer1_timeout()) {
        if(modbus_recv_pdu(&pdu) == MODBUS_OK && (pdu.function == 0x10)) {
            if(pdu.data[0] == SPM_PAGESIZE) {
                for(uint16_t i = 0; i < pdu.data[0]; i++) {
                    spm_buffer[i] = pdu.data[i + 1];
                }
            } else {
                // We've got too many or too little data!
                // To keep this bootloader simple and small do not try to
                // recover or send exception.
                break;
            }

            // Word address to byte address.
            spm_address = (pdu.address * 2);
            write_page(spm_address, spm_buffer, SPM_PAGESIZE);

            #ifdef DEBUG_MODBUS
            modbus_print_pdu(&pdu);
            #endif

            modbus_send_pdu(&pdu);
            timer1_start(); // Restart timer.
        } // end if
    } // end while
}

void __do_copy_data (void) __attribute__ ((naked)) __attribute__ ((section (".text9")));
void __do_copy_data (void) {}
void __do_clear_bss (void) __attribute__ ((naked)) __attribute__ ((section (".text9")));
void __do_clear_bss (void) {}

void start (void) __attribute__ ((naked)) __attribute__ ((section (".init0")));
void start (void) {
    asm volatile ( "ldi 16, %0" :: "i" (RAMEND >> 8) );
    asm volatile ( "out %0,16" :: "i" (AVR_STACK_POINTER_HI_ADDR) );
    asm volatile ( "ldi 16, %0" :: "i" (RAMEND & 0x0ff) );
    asm volatile ( "out %0,16" :: "i" (AVR_STACK_POINTER_LO_ADDR) );
    // GCC depends on register r1 set to 0
    asm volatile ( "clr __zero_reg__" );
    // set SREG to 0
    asm volatile ( "out %0, __zero_reg__" :: "I" (_SFR_IO_ADDR(SREG)) );

    // Note: If the Watchdog is accidentally enabled, for example by a runaway
    // pointer or brown-out condition, the device will be reset and the Watchdog
    // Timer will stay enabled. If the code is not set up to handle the Watchdog,
    // this might lead to an eternal loop of time-out resets. To avoid this
    // situation, the application software should always clear the Watchdog System
    // Reset Flag (WDRF) and the WDE control bit in the initialisation routine,
    // even if the Watchdog is not in use. (Datasheet p. 57.)
    mcusr = MCUSR;
    MCUSR = 0;
    wdt_reset();
    wdt_enable(WDTO_8S);

    wdt_reset();
    LED_INIT();
    LED_ON();

    // Initialize pins for modbus address.
    wdt_reset();
    MODBUS_ADDRESS_INIT();

    // Activate RS485/UART.
    wdt_reset();
    rs485_init();

    // Initialize Modbus
    wdt_reset();
    uint8_t slave = SLAVE_ADDRESS | MODBUS_ADDRESS_READ();
    modbus_init(slave);

    #ifdef DEBUG_MAIN
    rs485_output();
    rs485_putp(PSTR("Up and running\n"));
    rs485_putp(PSTR("SPM_PAGESIZE="));
    rs485_puthex2(SPM_PAGESIZE);
    rs485_putp(PSTR(", MCUSR="));
    rs485_puthex2(mcusr);
    rs485_putp(PSTR(", slave="));
    rs485_puthex2(slave);
    rs485_putc('\n');
    rs485_input();
    #endif

    // Wait some time for unlock message. (timer1 @16MHz ~ 1s)
    // If unlock message is received, the bootloader will wait for new
    // firmware data. otherwise it will start app.
    timer1_start();
    while(!timer1_timeout()) {
        // Receive one modbus message, check if message contains unlock secret.
        if(modbus_recv_pdu(&pdu) == MODBUS_OK) {
            if(
                (pdu.function) == 0x10 &&
                (pdu.address == UNLOCK_ADDRESS) &&
                (pdu.wsize == 2) &&
                *(uint32_t *)(pdu.data+1) == UNLOCK_SECRET
            ) {
                #ifdef DEBUG_MAIN
                rs485_output();
                rs485_putp(PSTR("BL unlocked.\n"));
                rs485_input();
                #endif

                // Delete first page -- interrupt vectors, this will
                // deactivate firmware.
                for(uint8_t i = 0; i < SPM_PAGESIZE; i++) {
                    spm_buffer[i] = 0;
                }
                write_page(0x0000, spm_buffer, SPM_PAGESIZE);

                // Send modbus response.
                modbus_send_pdu(&pdu);
                wdt_reset();
                // Now the bootloader is unlocked, download firmware.
                download_fw();
                break;
            } else {
                #ifdef DEBUG_MAIN
                rs485_output();
                rs485_putp(PSTR("BL locked.\n"));
                rs485_input();
                #endif
                break;
            }
        }
    }

    #ifdef DEBUG_MAIN
    rs485_output();
    rs485_putp(PSTR("\nStarting app\n"));
    rs485_input();
    #endif

    start_app();
    while(1); // Code should not reach here!
}
