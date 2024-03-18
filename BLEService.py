import pybleno
import array


SERVICE_UUID = '77670a58-1cb4-4652-ae7d-2492776d303d'

CHARACTERISTIC_UUID = '13092a53-7511-4ae0-8c9f-97c84cfb5d9a'

class Characteristic(pybleno.Characteristic):
    def __init__(self):
        pybleno.Characteristic.__init__(self, {
            'uuid': CHARACTERISTIC_UUID,
            'properties': ['read', 'write', 'notify'],
            'value': None
        })

        self._value = array.array('B', [0] * 0)

    def onReadRequest(self, offset, callback):
        print('Read request received')

        callback(self.RESULT_SUCCESS, self._value)

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        self._value = data
        print('Write request received:', data)

        if len(data) > 0:
            print('Data received:', data)

        callback(self.RESULT_SUCCESS)

    def onSubscribe(self, maxValueSize, updateValueCallback):
        print('Subscribed to')
        self._updateValueCallback = updateValueCallback

    def onUnsubscribe(self):
        print('Unsubscribed from')
        self._updateValueCallback = None

bleno = pybleno.Bleno()

def onStateChange(state):
    print('on -> stateChange: ' + state)

    if state == 'poweredOn':
        bleno.startAdvertising('Peripheral', [SERVICE_UUID])
    else:
        bleno.stopAdvertising()

bleno.on('stateChange', onStateChange)

def onAdvertisingStart(error):
    print('on -> advertisingStart: ' + ('error ' + error if error else 'success'))

    if not error:
        bleno.setServices([
            pybleno.Service({
                'uuid': SERVICE_UUID,
                'characteristics': [
                    Characteristic()
                ]
            })
        ])

bleno.on('advertisingStart', onAdvertisingStart)

bleno.start()
