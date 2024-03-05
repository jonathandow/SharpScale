import time
from adafruit_ble import BLERadio
from adafruit_ble.services import Service
from adafruit_ble.uuid import StandardUUID
from adafruit_ble.characteristics import Characteristic
from adafruit_ble.characteristics.int import Uint8Characteristic

class SimpleService(Service):
    uuid = StandardUUID(0x1234)
    recipe_char = Uint8Characteristic(uuid=StandardUUID(0x2345), properties=("read", "write"))
    ingredient_char = Uint8Characteristic(uuid=StandardUUID(0x3456), properties=("read", "write"))

ble = BLERadio()

service = SimpleService()
ble._adapter.services.add(service)

print("Advertising BLE service")
ble.start_advertising(service)

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    pass

ble.stop_advertising()
