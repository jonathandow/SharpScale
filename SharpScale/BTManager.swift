import CoreBluetooth
import os

class BTManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    @Published var peripherals: [CBPeripheral] = []
    @Published var peripheralNames: [String] = []
    let raspberryPiUUID = CBUUID(string: "77670a58-1cb4-4652-ae7d-2492776d303d")
    let recipeUUID = CBUUID(string: "13092a53-7511-4ae0-8c9f-97c84cfb5d9a")
    let ingredientUUID = CBUUID(string: "b36a0f4d-c30c-4b43-9710-231aeba7cdfa")
    private var raspberryPiPeripheral: CBPeripheral?
    private var recipeChar: CBCharacteristic?
    private var ingredientChar: CBCharacteristic?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: [raspberryPiUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: false)])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name ?? "No Name."
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
            peripheralNames.append(name)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([raspberryPiUUID])
    }
    
    func connectToDevice(peripheral: CBPeripheral){
        guard centralManager.state == .poweredOn else {
            print("CM Not On.")
            return
        }
        print("Connecting: %@", peripheral)
        centralManager.connect(peripheral, options:nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: %@", error.localizedDescription)
            return
        }
        
        guard let services = peripheral.services else {
            print("No services found")
            return
        }
        
        for service in services {
            if service.uuid == raspberryPiUUID {
                peripheral.discoverCharacteristics( nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            if let error = error {
                print("Error discovering characteristics: \(error.localizedDescription)")
                return
            }

            guard let characteristics = service.characteristics else {
                print("No characteristics found in service \(service.uuid)")
                return
            }

            for characteristic in characteristics {
                if characteristic.uuid == recipeUUID {
                    recipeChar = characteristic
                }
                if characteristic.uuid == ingredientUUID {
                    ingredientChar = characteristic
                }
            }
        }
}
// Path: /Desktop/SharpScale/SharpScale/ContentView.swift
