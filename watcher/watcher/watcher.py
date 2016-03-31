import builtins
import os
import re
import shlex
import subprocess
from time import sleep as time_sleep

from twisted.internet.defer import inlineCallbacks
from twisted.logger import Logger

from autobahn.twisted.util import sleep
from autobahn.twisted.wamp import ApplicationSession

from minimalmodbus import Instrument


DEBUG = os.environ.get('DEBUG', False)
DEBUG_PATH = '~/gates'

CYCLE_SLEEP = 0.04          # during each cycle, all instruments are readed; this is sleep time between each round
INSTRUMENT_SLEEP = 0.01     # sleep between ModBus read_registers calls; sleep time between individual gate reads

LED_ADDRESS = 0x0000
GATE_ADDRESS = 0x0000

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
        self.gates = extra['gates']
        self.log.info('list of gates: {gates}', gates=self.gates)
        self.instruments = {}
        self.led_gate = extra['led_gate']
        self.log.info('led gate: {gate}', gate=self.led_gate)
        self.keyboard_gate = extra['keyboard_gate']
        self.log.info('keyboard gate: {gate}', gate=self.keyboard_gate)
        # state
        self.watch_gates = False

    def init_instruments(self):
        for gate in self.gates:
            if DEBUG:
                self.instruments[gate] = None
            else:
                self.instruments[gate] = Instrument(self.port, gate)
                self.instruments[gate].serial.baudrate = 57600
                self.instruments[gate].serial.timeout = 1

    def init_debug(self):
        if not DEBUG:
            return
        self.GATE_RE = re.compile(r'^.+\/\d+\/\d+$')

        self.debug_path = os.path.expanduser(DEBUG_PATH)
        self.log.info('we are in debug mode, watching directory {path}', path=self.debug_path)

        if os.path.exists(self.debug_path) and os.path.isdir(self.debug_path):
            return
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
                response = None  # TODO: nevim jestli to nebudu muset osetrit jinak, v Dockeru se mi to tady seklo a vyhnilo; minimalne bych mel zurive logovat
            out[gate] = response
            time_sleep(INSTRUMENT_SLEEP)
        return out

    def read_instruments(self):
        if DEBUG:
            return self._read_fake_instruments()
        else:
            return self._read_real_instruments()

    def led_effect(self, mode):
        self.log.info("changing LED mode to {mode}", mode=mode)
        # self.instruments[self.led_gate].write_registers(LED_ADDRESS, mode) # TODO: neco jako; zatim to nemam implementovano
        # TODO: mozna bude treba samotny zapis resit uvnitr hlavni smycky kvuli konfliktum na sbernici

    def led_switch(self, number, color):
        self.log.info("changing LED #{number} to {color} color", number=number, color=color)
        # self.instruments[self.led_gate].write_registers(LED_ADDRESS, state) # TODO: neco jako; zatim to nemam implementovano
        # TODO: mozna bude treba samotny zapis resit uvnitr hlavni smycky kvuli konfliktum na sbernici

    def get_state_diff(self, old_state, new_state):
        if old_state is None:
            return new_state
        out = {}
        for k in old_state:
            if old_state[k] != new_state[k] and new_state[k] != 0:
                out[k] = new_state[k]
        return out

    @inlineCallbacks
    def onJoin(self, details):

        # events from javascript application
        def effect(mode):
            self.log.info("event for 'effect' received, mode '{mode}'", mode=mode)
            self.led_effect(mode)

        yield self.subscribe(effect, 'com.europe.effect')
        self.log.info("subscribed to topic 'effect'")

        def light(number, color):
            self.log.info("event for 'light' received: LED number={number}, color={color}", number=number, color=color)
            self.led_switch(number, color)

        yield self.subscribe(light, 'com.europe.light')
        self.log.info("subscribed to topic 'light'")

        def start(msg):
            self.log.info("event for 'start' received")
            self.led_effect(4)
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
        while True:
            value = self.read_instruments()
            diff = self.get_state_diff(old_value, value)
            if old_value != value:
                if self.keyboard_gate in diff:
                    yield self.publish('com.europe.keyboard', diff[self.keyboard_gate])
                    self.log.info("keypress detected {keys}, event 'com.europe.keyboard' published", keys=diff[self.keyboard_gate])
                    del diff[self.keyboard_gate]
                if self.watch_gates and len(diff) > 0:
                    yield self.publish('com.europe.gate', diff)
                    self.log.info("gate passing detected {diff}, event 'com.europe.gate' published", diff=diff)
                old_value = value
            yield sleep(CYCLE_SLEEP)
