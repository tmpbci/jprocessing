#!/usr/bin/env python

import BaseHTTPServer, urlparse, serial, ConfigParser, re, time, shutil, sys

class Handler(BaseHTTPServer.BaseHTTPRequestHandler):

    # Disable logging DNS lookups
    def address_string(self):
        return str(self.client_address[0])

    def do_GET(self):
        url = urlparse.urlparse(self.path)
        params = urlparse.parse_qs(url.query)
        path = url.path

        if path == '/':
            path = '/resources/index.html'
        elif path == '/favicon.ico':
            path = '/resources/favicon.ico'

        bits = path.lstrip('/').split('/')

        device = bits.pop(0) # Device
        if (device == '_'):
            devices = dmxDevices.keys()
        else:
            try:
                devices = device.split(',')
                devices = [int(x) for x in devices]
                for dev in devices:
                    if dev not in dmxDevices:
                        raise ValueError('Cannot find specified DMX device, available devices are: ')

            except ValueError, e:
                self.send_error(500)
                self.end_headers()
                self.wfile.write(e)
                self.wfile.write(', '.join(str(x) for x in dmxDevices.keys()))
                return 

        colour = bits.pop(0) # Colour
        try:
          coldev = colour.split(',')
          print coldev
          if re.match('\d+,\d+,\d+', colour):
              rgb = colour.split(',')
          elif re.match('[0-9ABCDEF]{,6}', colour):
              rgb = [int(x, 16) for x in (colour[0:2], colour[2:4], colour[4:6])]

          for val in rgb:
              if int(val) < 0 or int(val) > 255:
                  raise ValueError('RGB value out of range, should be 0 <> 255')

        except ValueError, e:
            self.send_error(500)
            self.end_headers()
            self.wfile.write(e)
            return 

        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write('OK')
        DMX.setColour(devices, rgb)

        global devices_old, rgb_old
        if 'restoreAfter' in params:
            time.sleep(float(params['restoreAfter'][0]))
            DMX.setColour(devices_old, rgb_old)
        else:
            devices_old = devices
            rgb_old = rgb

class ArduinoShield:

    def __init__(self, port):
        self.port = serial.Serial(port, 115200, timeout=1)

    def setColour(self, devices, rgb):
        for device in devices:
            for i in range(0, 3):
                self.port.write("%sc%sw" % (dmxDevices[device] + i, rgb[i]))
        
class EnttecDmxPro:

    START_OF_MESSAGE = 0x7e
    END_OF_MESSAGE = 0xe7
    SEND_DMX = 6

    def __init__(self, port):
        self.port = serial.Serial(port, 57600, timeout=1)

    def setColour(self, devices, rgb):
        packet = ["\0"] * 513
        for device in devices:
            for i in range(0, 3):
                packet[dmxDevices[device] + i] = chr(rgb[i])
        self.sendMsg(self.SEND_DMX, ''.join(packet))

    def sendMsg(self, msgtype, msg):
        self.port.write("%c%c" % (self.START_OF_MESSAGE, msgtype))
        self.port.write("%c%c" % (len(msg) & 0xff, (len(msg) >> 8) & 0xff))
        self.port.write(msg)
        self.port.write("%c" % self.END_OF_MESSAGE)


config = ConfigParser.ConfigParser()
config.read((
    'lighted.conf',
    sys.path[0] + '/lighted.conf',
    '/etc/lighted.conf'
))

serialPort = config.get('lighted', 'serialport')
dmxType = config.get('lighted', 'controller')
try:
    dmxClass = {
        'arduino': ArduinoShield,
        'enttec':  EnttecDmxPro,
    }[dmxType.lower()]
except KeyError:
    raise KeyError('Invalid DMX controller')
else:
    DMX = dmxClass(serialPort)

devices = config.get('lighted', 'dmxdevices')
offsets = devices.split(',')

dmxDevices = {}
offset = 0
for device in offsets:
    offset += 1
    dmxDevices[offset] = int(device)

# Default to everything off
devices_old = dmxDevices.keys()
rgb_old = ['0','0','0']

PORT = config.getint('lighted', 'tcpport')
httpd = BaseHTTPServer.HTTPServer(("", PORT), Handler)
httpd.serve_forever()

