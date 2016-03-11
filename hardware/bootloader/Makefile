#------------------------------------------------------------------------------
#------------------------------------------------------------ configuration ---

TARGET = mbboot
VERSION=\"mb-`date +%d%m%y`\"

#--------------------------------
# Hardware specific configuration
#--------------------------------
# DEVICE = atmega1284p
# CLOCK = 16000000
# BOOTSTRING_START = 0x1f500
# TEXT_START = 0x1e000

DEVICE = atmega328p
CLOCK = 16000000
TEXT_START = 0x7c00
FUSES = -U lfuse:w:0xff:m -U hfuse:w:0xdc:m

# DEVICE = atmega168
# CLOCK = 16000000
# TEXT_START = 0x3c00
# FUSES = -U lfuse:w:0xff:m -U hfuse:w:0xdf:m -U efuse:w:0xfa:m -B 10

#----------------------------
# Programmer type and options
#----------------------------
PROGRAMMER = -c avrispmkii

#------
# Tools
#------
AVRDUDE = avrdude
CC = avr-gcc
OBJCOPY = avr-objcopy
AVR-SIZE = avr-size
OBJDUMP = avr-objdump

#------------------------------------------------------------------------------
#----------------------------------------- no user serviceable parts inside ---
.PHONY: all clean flash fuses
OBJECTS    = $(TARGET).o rs485.o flash.o modbus.o timer.o
INCLUDES = -I.

PROGRAM = $(AVRDUDE) $(PROGRAMMER) -p $(DEVICE)
# LDFLAGS += -Wl,--section-start=.bootstring=$(BOOTSTRING_START)
LDFLAGS += -Wl,--section-start=.text=$(TEXT_START)
LDFLAGS += -Wl,--relax
LDFLAGS += -Wl,--gc-sections
LDFLAGS += -nostartfiles
LDFLAGS += -nostdlib

CFLAGS += -std=gnu99
CFLAGS += -Os
CFLAGS += -mmcu=$(DEVICE)
CFLAGS += -Wall
CFLAGS += -Winline
CFLAGS += -Wstrict-prototypes
CFLAGS += -ffunction-sections
CFLAGS += -fdata-sections
CFLAGS += -funsigned-char
CFLAGS += -fno-move-loop-invariants
CFLAGS += -fdiagnostics-color=always
CFLAGS += $(INCLUDES)
CFLAGS += -DNRWW_START=$(TEXT_START)
CFLAGS += -DF_CPU=$(CLOCK)

# default target
all: hex bin size

help:
	@echo
	@echo Help:
	@echo  make ....................... compile bootloader for ATMega328P
	@echo  make flash ................. flash bootloader to device
	@echo  make clean ................. clean all

clean:
	rm -f $(TARGET).hex $(TARGET).elf $(TARGET).bin $(TARGET).lst $(OBJECTS)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

flash:	all
	$(PROGRAM) -U flash:w:$(TARGET).hex:i

hex: $(TARGET).hex

bin: $(TARGET).bin

fuses:
	# $(PROGRAM) -e $(UNLOCK_FUSE)
	$(PROGRAM) $(FUSES)

disasm:	$(TARGET).elf
	$(OBJDUMP) -d $(TARGET).elf

$(TARGET).elf: $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

$(TARGET).hex: $(TARGET).elf
	rm -f $(TARGET).hex
	$(OBJCOPY) -j .bootstring -j .text -O ihex $(TARGET).elf $(TARGET).hex

$(TARGET).bin: $(TARGET).elf
	rm -f $(TARGET).bin
	$(OBJCOPY) -j .bootstring -j .text -O binary $(TARGET).elf $(TARGET).bin

size: $(TARGET).elf
	@echo "    SIZES             ATmega...  '88P      '168       '328    '1284P"
	@$(OBJDUMP) -h $^ | perl -MPOSIX -ne '/.(text)\s+([0-9a-f]+)/ && do { $$a += eval "0x$$2" }; END { printf "    FLASH : %5d bytes          %3d%%      %3d%%       %3d%%      %3d%%\n", $$a, ceil($$a * 100 / (2 * 1024)), ceil($$a * 100 / (2 * 1024)),ceil($$a * 100 / (4 * 1024)), ceil($$a * 100 / (8 * 1024)) }'
	@$(OBJDUMP) -h $^ | perl -MPOSIX -ne '/.(data|bss)\s+([0-9a-f]+)/ && do { $$a += eval "0x$$2" }; END { printf "    RAM   : %5d bytes          %3d%%      %3d%%       %3d%%      %3d%%\n", $$a, ceil($$a * 100 / (1 * 1024)), ceil($$a * 100 / (1 * 1024)),ceil($$a * 100 / (2 * 1024)), ceil($$a * 100 / (16 * 1024)) }'
	@$(OBJDUMP) -h $^ | perl -MPOSIX -ne '/.(eeprom)\s+([0-9a-f]+)/ && do { $$a += eval "0x$$2" }; END { printf "    EEPROM: %5d bytes          %3d%%      %3d%%       %3d%%      %3d%%\n", $$a, ceil($$a * 100 / (0.5 * 1024)), ceil($$a * 100 / (0.5 * 1024)), ceil($$a * 100 / (1 * 1024)), ceil($$a * 100 / (4 * 1024)) }'


