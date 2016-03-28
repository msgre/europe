#!/usr/bin/env python

NEOPIXEL_SIZE = 24
COLORLENGTH = NEOPIXEL_SIZE / 4
FADE = 2

BRIGHTNESS = 1

# Rainbow colors.
RAINBOW = [
    # [R,   G,   B],
    [0x8, 0x8, 0x8],  # white
    [0xF, 0x0, 0x0],  # red
    [0xF, 0x6, 0x0],  # orange
    [0x6, 0xF, 0x0],  # yellow
    [0x0, 0xF, 0x0],  # green
    [0x0, 0x6, 0xF],  # light blue
    [0x0, 0x0, 0xF],  # blue
    [0x6, 0x0, 0xF],  # violet
]


def to_color(color, brightness=BRIGHTNESS):
    r = color[0]
    g = color[1]
    b = color[2]
    return (brightness << 12) | (r << 8) | (g << 4) | b

if __name__ == '__main__':
    import sys
    import signal
    import time
    from minimalmodbus import Instrument

    if len(sys.argv) < 3:
        print 'Usage: {} [COM] [SLAVE] <baudrate=57600>'.format(sys.argv[0])
        exit(1)

    port = sys.argv[1]
    slave = int(sys.argv[2])
    try:
        baudrate = int(sys.argv[3])
    except Exception:
        baudrate = 57600

    instrument = Instrument(port, slave)
    instrument.serial.baudrate = baudrate
    instrument.serial.timeout = 1

    def signal_handler(signal, frame):
        print('Turning all LEDs off.')
        instrument.write_registers(0x1000, [0x0000] * NEOPIXEL_SIZE)
        sys.exit(0)
    signal.signal(signal.SIGINT, signal_handler)

    led = [[0, 0, 0] for x in xrange(NEOPIXEL_SIZE)]
    j = 1
    k = 1

    print 'Rainbow.'
    while True:
        # Shift all values by one led.
        led.insert(0, list(led[0]))
        led = led[:-1]

        # Change color when colour length is reached.
        if k > COLORLENGTH:
            j += 1
            if j >= len(RAINBOW):
                j = 0
            k = 0
        k += 1

        # Fade first LED.
        if led[0][0] < (RAINBOW[j][0] - FADE):
            led[0][0] += FADE
        if led[0][0] > (RAINBOW[j][0] + FADE):
            led[0][0] -= FADE
        if led[0][1] < (RAINBOW[j][1] - FADE):
            led[0][1] += FADE
        if led[0][1] > (RAINBOW[j][1] + FADE):
            led[0][1] -= FADE
        if led[0][2] < (RAINBOW[j][2] - FADE):
            led[0][2] += FADE
        if led[0][2] > (RAINBOW[j][2] + FADE):
            led[0][2] -= FADE

        instrument.write_registers(0x1000, map(to_color, led))
        time.sleep(0.05)
