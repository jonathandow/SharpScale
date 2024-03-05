import bluetooth
from bluetooth.ble import GATTRequestHandler, GATTResponse, AdvertisementData, Service, Characteristic, Descriptor
from uuid import uuid4

SERVICE_UUID = "77670a58-1cb4-4652-ae7d-2492776d303d"
RECIPE_CHAR_UUID = "b0126643-a97d-4df2-9ba1-9b9659493f8a"
INGREDIENT_CHAR_UUID = "1f8d9c4c-58bc-468b-9bc8-37d81cf1914d"

class BLEPeripheral(GATTRequestHandler):
    def __init__(self):
        self.service = Service(SERVICE_UUID, True) 
        self.recipe_char = Characteristic(RECIPE_CHAR_UUID, ["read", "write"], self.service)
        self.ingredient_char = Characteristic(INGREDIENT_CHAR_UUID, ["read", "write"], self.service)

    def on_read_request(self, characteristic, offset):
        if characteristic.uuid == RECIPE_CHAR_UUID:
            return GATTResponse(characteristic.value)
        elif characteristic.uuid == INGREDIENT_CHAR_UUID:
            return GATTResponse(characteristic.value)
        else:
            return GATTResponse("Unknown Characteristic", True)
        
    def on_write_request(self, characteristic, value, offset):
        characteristic.value = value
        return GATTResponse("")
    
    def start(self):
        adapter = bluetooth.get_default_adapter()
        adapter.power_on()
        print("Advertising BLE Service...")
        adapter.start_advertising(AdvertisementData(local_name="Raspberry Pi [SharpScale]"), self.service)
        while True:
            bluetooth.ble.request_discovery(adapter)

if __name__ == "__main__":
    peripheral = BLEPeripheral()
    peripheral.start()


"""
from bluepy.btle import Peripheral, Service, Characteristic, UUID

# UUIDs for your service and characteristics
SERVICE_UUID = "12345678-1234-5678-1234-56789abcdef0"
RECIPE_CHAR_UUID = "abcdef01-1234-5678-1234-56789abcdef0"
INGREDIENT_CHAR_UUID = "abcdef02-1234-5678-1234-56789abcdef0"

class SimpleBLEPeripheral(Peripheral):
    def __init__(self, service_uuid, recipe_char_uuid, ingredient_char_uuid):
        Peripheral.__init__(self)

        self.service = Service(UUID(service_uuid), True)
        self.addService(self.service)

        self.recipe_char = Characteristic(UUID(recipe_char_uuid), Characteristic.props["READ"] | Characteristic.props["WRITE"], Characteristic.perms["READ"] | Characteristic.perms["WRITE"], 0)
        self.service.addCharacteristic(self.recipe_char)

        self.ingredient_char = Characteristic(UUID(ingredient_char_uuid), Characteristic.props["READ"] | Characteristic.props["WRITE"], Characteristic.perms["READ"] | Characteristic.perms["WRITE"], 0)
        self.service.addCharacteristic(self.ingredient_char)

if __name__ == "__main__":
    peripheral = SimpleBLEPeripheral(SERVICE_UUID, RECIPE_CHAR_UUID, INGREDIENT_CHAR_UUID)
    try:
        peripheral.advertise("Raspberry Pi BLE")
        print("Peripheral is advertising")
        while True:
            peripheral.waitForNotifications(1.0)
    finally:
        peripheral.disconnect()
"""
