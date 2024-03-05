import bluetooth
from bluetooth.ble import GATTRequestHandler, GATTResponse, AdvertisementData, Service, Characteristic, Descriptor
from uuid import uuid4

SERVICE_UUID = str(uuid4())
RECIPE_CHAR_UUID = str(uuid4())
INGREDIENT_CHAR_UUID = str(uuid4())

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