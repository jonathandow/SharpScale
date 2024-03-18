import bleno
from bleno import Characteristic
import sys
import signal

class CustomCharacteristic(Characteristic):
    def __init__(self):
        Characteristic.__init__(self, {
            'uuid': '13092a53-7511-4ae0-8c9f-97c84cfb5d9a',
            'properties': ['read', 'write'],
            'value': None
        })

    def onReadRequest(self, offset, callback):
        print("Read request received")
        callback(Characteristic.RESULT_SUCCESS, "Data to send")

    def onWriteRequest(self, data, offset, withoutResponse, callback):
        print(f"Write request received: {data}")
        callback(Characteristic.RESULT_SUCCESS)

bleno = bleno.Bleno()

class CustomService(bleno.PrimaryService):
    def __init__(self):
        bleno.PrimaryService.__init__(self, {
            'uuid': '77670a58-1cb4-4652-ae7d-2492776d303d', 
            'characteristics': [
                CustomCharacteristic()
            ]
        })

service = CustomService()

def main():
    bleno.start()

    print('Advertising service...')
    bleno.setServices([service])

    try:
        while True:
            pass
    except KeyboardInterrupt:
        pass
    finally:
        print('Stopping BLE peripheral...')
        bleno.stop()

if __name__ == '__main__':
    main()
