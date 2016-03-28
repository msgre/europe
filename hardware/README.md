# Hardware

Europe's hardware consists of two boards -- gate and IR.

To detect active gate the IR board contains reflective IR photointerrupter.
This board has to be powered by 5 VDC, the output signal is 5V (no activity)
or 0V (GND, gate was activated).

Up to six IR boards can be connected to one "gate board". This board can supply
5V to all connected IR gates and register their output signal. Gate board have
to be powered by 5VDC from RS485 bus. The Modbus is used to read status of all
IR gates connected to one gate board.

Each gate board has 4 solder jumpers for Modbus slave address. Their
firmware can be updated via Modbus.

## Overview

- `eagle`, `gerber` and `pdf` -- documentation for manufacturing this hardware.
- `bootloader` -- source code of Modbus bootloader for ATMegaXX8P.
- `src` -- main firmware for gate boards.
- `neopixel` -- control Neopixel (WS2812) LEDs via Modbus.
- `examples` -- simple Python examples, how to control and update gates over Modbus.

## Bootloader and Firmware

To make firmware for AVR the avr-gcc and avrdude is needed. Bootloader and firmware
can be compiled by `make`.

Programming bootloader to connected board (you will need AVRispmkII programmer):

    $ cd bootloader
    $ make
    $ make fuses && make flash

If programming was successful, the green onboard LED should be permanently turned on.
This indicates the bootloader is running and accepting Modbus commands.

Main firmware can be compiled like this:

    $ cd src
    $ make

This will create `main.bin` file which can be used with Modbus bootloader like
this:

    $ ./examples/modbus_update.py /dev/usbserial.XYZ addr ./src/main.bin

## Neopixel Firmware

Special firmware version for interfacing WS2812 LEDs through Modbus is
in directory `neopixel`. This firmware can be compiled the same way as main
firmware:

    $ cd neopixel
    $ make

This special firmware has the same modbus registers as main firmware (inputs,
reset, HW&FW version) and aditional address space `0x1000`. One register in
this space represents one Neopixel LED. The bit mapping is:

    +-------------------------------+-------------------------------+
    |         High byte             |            Low byte           |
    +-------------------------------+-------------------------------+
    | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
    +-------------------------------+-------------------------------+
    | L | L | L | L | R | R | R | R | G | G | G | G | B | B | B | B |
    +-------------------------------+-------------------------------+

where `R` = red, `G` = green, `B` = blue, `L` = brightness. For example:

    0x1F00 = red
    0x10F0 = green
    0x100F = blue
    0x16F0 = yellow
    0x06F0 = yellow, minimum brightness.
    0xF6F0 = yellow, maximum brightness.

Neopixels should be connected to the pin PWM0 (AVR pin PD6).

## Modbus Address

The slave address is selected by solder jumpers SJ1-SJ4. Soldered jumper represent
LOW, thus connecting SJ3 and SJ4 makes address `0x03`.

The bootloader slave address has MSB set -- for example `0x03 -> 0x83`.

## Modbus Registers

Modbus register is 16 bit integer. The firmware has three registers on addresses:

- `0x0000` 0x00XX; IR gates state since last Modbus reading or FW reset.
- `0x0001` 0xXYYY; firmware (Y) and hardware (X) version
- `0x0002` reset; any writes to this register will trigger FW reset in 500ms.

## Python Examples

Tested with Python 2.7, pyserial 3.0.1 and minimalmodbus 0.7.

    $ pip install pyserial
    $ pip install minimalmodbus

To update firmware in board with slave address 15 (0x0F), bootloader address is
143 (0x8F):

    $ cd ./examples
    $ ./modbus_update.py /dev/usbserial.XYZ 15 ./firmware.bin

To read latest gate states from board with slave address 15 (0x0F):

    $ ./examples/modbus_read.py /dev/usbserial.XYZ 15

Slave dicovery on bus can be done by:

    $ ./examples/modbus_discover.py /dev/usbserial.XYZ

To use neopixel firmware on slave 13 (example expects 24 WS2812 LEDs):

    $ ./examples/neopixel_rainbow.py /dev/usbserial.XYZ 13

## Wires

There are two types of wires.

First wire is for RS485/Modbus and connects
together gate boards. This is at least 2 twisted pairs with RJ12 (6p6c) on both
ends. All gate boards are daisy chained from first to last board and to Modbus
master.

Second type of wire connects IR boards with gate boards. This is 3 core flat
cable and 3 pins connectors with 2.54mm (0.1'') pitch. KK254 Molex or NS25 Ninigi
types can be used.

### RS485/Modbus Wires

**TODO**

### IR Boards Wires

Prepare flat wire, connector housing and pins.

![IR wire components](https://github.com/msgre/europe/blob/master/hardware/imgs/wire-ir-01-components.jpg)

Crimp pins to wire on both ends. Used crimping tool: Engineer PA-09.

![IR wire crimping tool](https://github.com/msgre/europe/blob/master/hardware/imgs/wire-ir-02-crimping.jpg)

Correct pins orientation on wire.

![IR wire with pins](https://github.com/msgre/europe/blob/master/hardware/imgs/wire-ir-03-pins.jpg)

Finished wire.

![Finished IR wire](https://github.com/msgre/europe/blob/master/hardware/imgs/wire-ir-04-finished.jpg)
