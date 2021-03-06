import builtins
import os
import re
import shlex
import subprocess
from pathlib import Path
from time import sleep as time_sleep

from twisted.internet.defer import inlineCallbacks
from twisted.logger import Logger

from autobahn.twisted.util import sleep
from autobahn.twisted.wamp import ApplicationSession

from minimalmodbus import Instrument

import neopixels


DEBUG = os.environ.get('DEBUG', False)
LED_OFF = os.environ.get('LED_OFF', False)
DEBUG_PATH = '~/gates'
POWEROFF_PATH = '~/poweroff'

# TODO: try lower to 0.02 value, we have now 2 separate ModBus instrutions in main loop
CYCLE_SLEEP = 0.005          # during each cycle, all instruments are readed; this is sleep time between each round
INSTRUMENT_SLEEP = 0.005     # sleep between ModBus read_registers calls; sleep time between individual gate reads

GATE_ADDRESS = 0x0000

KEYBOARD_REPEAT_COUNTER = 0
KEYBOARD_WAIT_COUNTER = 7


class AppSession(ApplicationSession):

    log = Logger()
    state = None

    def __init__(self, config):
        self.init_debug()
        self.init(config.extra)
        self.init_instruments()
        ApplicationSession.__init__(self, config)

    def init(self, extra):
        # hardware configuration
        self.port = self.find_usb_device(extra['usb_regex'])
        self.instruments = {}
        self.led_gate = extra['led_gate']
        self.log.info('led gate: {gate}', gate=self.led_gate)
        self.keyboard_gate = extra['keyboard_gate']
        self.log.info('keyboard gate: {gate}', gate=self.keyboard_gate)
        self.poweroff_button = extra['poweroff_button']
        self.log.info('poweroff button: {button}', button=self.poweroff_button)
        self.gates = extra['gates'] + [self.keyboard_gate]
        self.log.info('list of gates: {gates}', gates=self.gates)

        # directory for poweroff flag
        self.poweroff_path = os.path.expanduser(POWEROFF_PATH)
        self.log.info('poweroff directory is set to {path}', path=self.poweroff_path)
        if not os.path.exists(self.poweroff_path):
            os.makedirs(self.poweroff_path)
        
        # state
        self.watch_gates = False
        
        # neopixel's LED
        self.neopixel = None

    def init_instruments(self):
        for gate in self.gates:
            if DEBUG:
                self.instruments[gate] = None
            else:
                self.instruments[gate] = Instrument(self.port, gate)
                self.instruments[gate].serial.baudrate = 57600
                self.instruments[gate].serial.timeout = 1
        if DEBUG:
            self.led_instrument = None
        else:
            self.led_instrument = Instrument(self.port, self.led_gate)
            self.led_instrument.serial.baudrate = 57600
            self.led_instrument.serial.timeout = 1

    def init_debug(self):
        if not DEBUG:
            return
        self.GATE_RE = re.compile(r'^.+\/\d+\/\d+$')

        self.debug_path = os.path.expanduser(DEBUG_PATH)
        self.log.info('we are in debug mode, watching directory {path}', path=self.debug_path)

        if not os.path.exists(self.debug_path):
            os.makedirs(self.debug_path)

    def find_usb_device(self, regex):
        if DEBUG:
            return None
        m = re.compile(regex)
        out = [i for i in os.listdir('/dev') if m.match(i)]
        if len(out) < 1:
            self.log.warn('usb device not found: regexp pattern {regexp}', regexp=regexp)
            assert False
        path = '/dev/' + out[0]
        self.log.info('usb device found: {path}', path=path)
        return path

    def _read_fake_instruments(self):
        # read directory structure and look for files like ~/gates/1/1
        out = {}
        files = [i.decode('ascii').split('/')[-2:] \
                 for i in subprocess.check_output(['find', self.debug_path]).splitlines() \
                 if self.GATE_RE.match(i.decode('ascii'))]
        files = sorted(files, key=lambda a: a[0])

        # construct fake instrument structure
        for gate in self.instruments:
            out[gate] = 0
        for f in files:
            out[int(f[0])] = int(f[1])
            time_sleep(INSTRUMENT_SLEEP)

        # remove files in ~/gates
        for parts in files:
            path = os.path.join(self.debug_path, *parts)
            cmd = 'rm {path}'.format(path=path)
            subprocess.call(shlex.split(cmd))
        return out

    def _read_real_instruments(self):
        out = {}
        for gate in self.instruments:
            try:
                response = self.instruments[gate].read_registers(GATE_ADDRESS, 1)[0]
            except builtins.OSError:
                self.log.warn("problem with gate #{}".format(gate))
                response = None  # TODO: nevim jestli to nebudu muset osetrit jinak, v Dockeru se mi to tady seklo a vyhnilo; minimalne bych mel zurive logovat
            out[gate] = response
            time_sleep(INSTRUMENT_SLEEP)
        return out

    def read_instruments(self):
        if DEBUG:
            return self._read_fake_instruments()
        else:
            return self._read_real_instruments()

    def get_state_diff(self, old_state, new_state):
        if old_state is None:
            return new_state
        out = {}
        for k in old_state:
            if k in [self.led_gate, self.keyboard_gate]:
                continue
            if old_state[k] != new_state[k] and new_state[k] != 0:
                out[k] = new_state[k]
        return out

    def register_neopixel(self, klass, **kwargs):
        if LED_OFF:
            return
        if self.neopixel:
            self.neopixel.stop()
            time_sleep(CYCLE_SLEEP)
        self.neopixel = klass(self.led_instrument, **kwargs)
        self.neopixel.start()

    @inlineCallbacks
    def onJoin(self, details):
        self.register_neopixel(neopixels.NeopixelsBlank)

        # neopixels effects
        def flash(msg):
            self.log.info("event for 'flash' received")
            self.register_neopixel(neopixels.NeopixelsFlash)

        yield self.subscribe(flash, 'com.europe.flash')
        self.log.info("subscribed to topic 'flash'")

        def blink(stale_leds, stale_color, blinking_leds, blinking_color):
            self.log.info("event for 'blink' received: stale LEDs={stale_leds}, stale color={stale_color}, blinking LEDs={blinking_leds}, blinking color={blinking_color}", stale_leds=stale_leds, stale_color=stale_color, blinking_leds=blinking_leds, blinking_color=blinking_color)
            self.register_neopixel(neopixels.NeopixelsBlink, stale_leds=stale_leds, stale_color=stale_color, blinking_leds=blinking_leds, blinking_color=blinking_color)

        yield self.subscribe(blink, 'com.europe.blink')
        self.log.info("subscribed to topic 'blink'")

        def noise(msg):
            self.log.info("event for 'noise' received")
            self.register_neopixel(neopixels.NeopixelsNoise)

        yield self.subscribe(noise, 'com.europe.noise')
        self.log.info("subscribed to topic 'noise'")

        def blank(msg):
            self.log.info("event for 'blank' received")
            self.register_neopixel(neopixels.NeopixelsBlank)

        yield self.subscribe(blank, 'com.europe.blank')
        self.log.info("subscribed to topic 'blank'")

        def rainbow(msg):
            self.log.info("event for 'rainbow' received")
            self.register_neopixel(neopixels.NeopixelsRainbow)

        yield self.subscribe(rainbow, 'com.europe.rainbow')
        self.log.info("subscribed to topic 'rainbow'")

        # game logic
        def start(msg):
            self.log.info("event for 'start' received")
            self.watch_gates = True
            self.log.info("watching of gates started")

        yield self.subscribe(start, 'com.europe.start')
        self.log.info("subscribed to topic 'start'")

        def stop(msg):
            self.log.info("event for 'stop' received")
            self.watch_gates = False
            self.log.info("watching of gates stopped")

        yield self.subscribe(stop, 'com.europe.stop')
        self.log.info("subscribed to topic 'stop'")


        # main cycle fow watching gates
        old_value = self.read_instruments()

        last_key_value = None
        last_key_value_counter = 20

        while True:
            # read state from gate boards
            value = self.read_instruments()
            diff = self.get_state_diff(old_value, value)
            if old_value != value:
                if self.watch_gates and len(diff) > 0:
                    if len([i for i in diff.values() if i == None]) == len(diff.values()):
                        self.log.info("None gate detected {diff}, no event 'com.europe.gate' published", diff=diff)
                    else:
                        yield self.publish('com.europe.gate', diff)
                        self.log.info("gate passing detected {diff}, event 'com.europe.gate' published", diff=diff)
                old_value = value
            
            # tlacitka
            if self.keyboard_gate in value:
                # event on button (press or release)
                if value[self.keyboard_gate] == 0:
                    # released button
                    last_key_value = None
                else:
                    # pressed button
                    if value[self.keyboard_gate] & self.poweroff_button:
                        # poweroff button
                        self.log.warn("PowerOff button pressed")
                        Path(os.path.join(self.poweroff_path, 'flag')).touch()
                    else:
                        if value[self.keyboard_gate] == last_key_value:
                            # same button, still pressed
                            if last_key_value_counter < 1:
                                self.log.info("repeated key value detected {keys}, event 'com.europe.keyboard' published", keys=value[self.keyboard_gate])
                                yield self.publish('com.europe.keyboard', value[self.keyboard_gate])
                                last_key_value_counter = KEYBOARD_REPEAT_COUNTER
                            else:
                                last_key_value_counter -= 1
                        else:
                            # new pressed button
                            self.log.info("new key value detected {keys}, event 'com.europe.keyboard' published", keys=value[self.keyboard_gate])
                            yield self.publish('com.europe.keyboard', value[self.keyboard_gate])
                            last_key_value = value[self.keyboard_gate]
                            last_key_value_counter = KEYBOARD_WAIT_COUNTER

                if self.keyboard_gate in diff:
                    del diff[self.keyboard_gate]


            yield sleep(CYCLE_SLEEP/3.0)

            # control neopixels
            if not LED_OFF and self.neopixel and self.neopixel.is_running:
                self.neopixel.step()
            yield sleep(CYCLE_SLEEP)
