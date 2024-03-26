from pybleno import Bleno, BlenoPrimaryService, Characteristic
import time
import sys
import signal

SERVICE_UUID = '77670a58-1cb4-4652-ae7d-2492776d303d'
CHARACTERISTIC_UUID = '13092a53-7511-4ae0-8c9f-97c84cfb5d9a'
DEVICE_NAME = "RaspberryPi5_BLE"

class MyChar(Characteristic):
	def __init__(self):
		Characteristic.__init__(self, {
			'uuid': CHARACTERISTIC_UUID,
			'properties': ['read', 'write', 'notify'],
			'value': None
		})
	
	def onReadRequest(self, offset, callback):
		print("Read Request")
		data = "Hello!"
		callback(Characteristic.RESULT_SUCCESS, bytearray(data, 'utf-8'))
		
bleno = Bleno()
myCharacteristic = MyChar()

def on_start(success):
	print("Bleno Starting... {}".format(success))
	if success:
		service = BlenoPrimaryService({
			'uuid': SERVICE_UUID,
			'characteristics': [myCharacteristic]
		})
		bleno.setServices([service])
		
def on_state_change(state):
	if state == 'poweredOn':
		bleno.startAdvertising(DEVICE_NAME, [SERVICE_UUID])
	else:
		bleno.stopAdvertising()

def signal_handler(signal, frame):
    print('You pressed Ctrl+C!')
    bleno.stopAdvertising()
    bleno.disconnect()

    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
		
bleno.on('stateChange', on_state_change)
bleno.on('advertisingStart', on_start)

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    pass
finally:
    bleno.stopAdvertising()
    bleno.disconnect()
