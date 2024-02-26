import CoreBluetooth

protocol BTManagerDelegate: AnyObject {
    func didUpdateConnectionStatus(connected: Bool)
}

class BTManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var raspberryPiPeripheral: CBPeripheral?
    var recipeCharacteristic: CBCharacteristic?
    var ingredientCharacteristic: CBCharacteristic?
    weak var delegate: BTManagerDelegate?

    let raspberryPiServiceUUID = CBUUID(string: "1234")
    let recipeCharacteristicUUID = CBUUID(string: "1234")
    let ingredientCharacteristicUUID = CBUUID(string: "1234")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    func sendData(data: Data, forCharactersiticUUID uuid: CBUUID) {
        guard let peripheral = raspberryPiPeripheral,
              let characteristic = findCharacteristic(by: uuid, in: peripheral) else {
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func startConnectionProcess() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [raspberryPiServiceUUID], options: nil)
        } else {
            print("Bluetooth Unavailable")
            return
        }
    }
    
    private func findCharacteristic(by uuid: CBUUID, in peripheral: CBPeripheral) -> CBCharacteristic? {
        guard let services = peripheral.services else { return nil }
        for service in services {
            guard let characteristics = service.characteristics else { continue }
            for characteristic in characteristics {
                if characteristic.uuid == uuid {
                    return characteristic
                }
            }
        }
        return nil
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "1234")], options: nil)
        } else {
            print("Bluetooth is not available.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        raspberryPiPeripheral = peripheral
        raspberryPiPeripheral?.delegate = self
        centralManager.stopScan()
        centralManager.connect(raspberryPiPeripheral!, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([raspberryPiServiceUUID])
        delegate?.didUpdateConnectionStatus(connected:true)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            delegate?.didUpdateConnectionStatus(connected: false)
        }


    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([recipeCharacteristicUUID, ingredientCharacteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == recipeCharacteristicUUID {
                recipeCharacteristic = characteristic
            } else if characteristic.uuid == ingredientCharacteristicUUID {
                ingredientCharacteristic = characteristic
            }
        }
    }

    func sendRecipeData(_ data: Data) {
        guard let characteristic = recipeCharacteristic else { return }
        raspberryPiPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }

    func sendIngredientData(_ data: Data) {
        guard let characteristic = ingredientCharacteristic else { return }
        raspberryPiPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }

    func readRecipeData() {
        guard let characteristic = recipeCharacteristic else { return }
        raspberryPiPeripheral?.readValue(for: characteristic)
    }

    func readIngredientData() {
        guard let characteristic = ingredientCharacteristic else { return }
        raspberryPiPeripheral?.readValue(for: characteristic)
    }
}
