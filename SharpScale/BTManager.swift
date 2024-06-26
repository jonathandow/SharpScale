import CoreBluetooth
import Foundation

class BTManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    @Published var connectionStatus: String = "Disconnected"
    private let testUUID = CBUUID(string: "5E434CBB-60DB-82C2-5274-59681535F4FC")
    private let serviceUUID = CBUUID(string: "77670a58-1cb4-4652-ae7d-2492776d303d")
    private var raspberryPiPeripheral: CBPeripheral?
    private let databaseUpdateCharacteristicUUID = CBUUID(string: "dd444f51-3cde-4d0e-b5fb-f81663f16839")
    private var dataChunks: [Data] = []
    private var currentChunkIndex = 0
    let dbHelper = SQLiteHelper()
    @Published var isConnected: Bool = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    func initiateDatabaseUpdate() {
        guard let peripheral = raspberryPiPeripheral else {
            print("Peripheral Not found.")
            return
        }
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            connectionStatus = "Scanning for Raspberry Pi 5..."
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        case .poweredOff:
            connectionStatus = "Bluetooth on this device is currently powered off."
        case .unsupported:
            connectionStatus = "This device does not support Bluetooth."
        case .unauthorized:
            connectionStatus = "This app is not authorized to use Bluetooth."
        case .resetting:
            connectionStatus = "The Bluetooth service is resetting; your device may need to be restarted."
        case .unknown:
            connectionStatus = "The state of the Bluetooth service is unknown."
        @unknown default:
            connectionStatus = "An unknown error has occurred with Bluetooth."
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let peripheralName = peripheral.name, peripheralName.contains("raspberrypi") else {
            print("Found a device, but it's not the Raspberry Pi: \(peripheral.name ?? "Unknown")")
            return
        }
        print("Raspberry Pi found: \(peripheralName)")
        centralManager.stopScan()
        raspberryPiPeripheral = peripheral
        raspberryPiPeripheral!.delegate = self
        centralManager.connect(raspberryPiPeripheral!, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        connectionStatus = "Connected to \(peripheral.name ?? "Raspberry Pi 5")"
        print(connectionStatus)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionStatus = "Failed to connect to \(peripheral.name ?? "device")"
        print(connectionStatus)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionStatus = "Disconnected"
        isConnected = false
        centralManager.connect(peripheral, options: nil)
        print(connectionStatus)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("finding service")
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        print(peripheral.services ?? "Hi")
        guard let services = peripheral.services else {
            print("no services found...")
            return
        }
        for service in services {
            print("Service found: \(service.uuid.uuidString)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovering Characteristics.....")
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else {
            print("No characteristics found")
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(databaseUpdateCharacteristicUUID){
                peripheral.setNotifyValue(true, for: characteristic)
                sendDBUpdate(toPeripheral: peripheral, forCharacteristic: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing characteristic \(characteristic.uuid): \(error.localizedDescription)")
            return
        }
        print("Wrote Chunk \(currentChunkIndex + 1)/\(self.dataChunks.count)")
        currentChunkIndex += 1
        if currentChunkIndex > self.dataChunks.count {
            currentChunkIndex = 0
            return
        }
        sendNextChunk(toPeripheral: peripheral, forCharacteristic: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("Peripheral services have been modified: \(invalidatedServices)")
    }
    
    func sendDBUpdate(toPeripheral periphal: CBPeripheral, forCharacteristic characteristic: CBCharacteristic) {
        print("Sending DB update...")
        let recipes = dbHelper.fetchAllRecipes()
        let ingredients = dbHelper.fetchAllIngredients()
        let databaseData = DatabaseData(recipes: recipes, ingredients: ingredients)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        print("Encoding...")
        if let jsonData = try? encoder.encode(databaseData) {
            if let peripheral = self.raspberryPiPeripheral {
                let maximumLength = peripheral.maximumWriteValueLength(for: .withResponse)
                self.dataChunks = jsonData.chunked(into: (maximumLength - 2))
                print("Prepared \(self.dataChunks.count) chunks of data")
                sendNextChunk(toPeripheral: peripheral, forCharacteristic: characteristic)
            }
        } else {
            print("failed to encode data...\n")
        }
    }
    
    func sendNextChunk(toPeripheral peripheral: CBPeripheral, forCharacteristic characteristic: CBCharacteristic) {
        if currentChunkIndex < self.dataChunks.count {
            let chunk = self.dataChunks[currentChunkIndex]
            print("Sending chunk...")
            peripheral.writeValue(chunk, for: characteristic, type: .withResponse)
        } else {
            print("EOT")
            return
        }
    }

    struct DatabaseData: Codable {
        let recipes: [Recipe]
        let ingredients: [Ingredient]
    }
}
extension Data {
    func chunked(into size: Int) -> [Data] {
        var chunks = [Data]()
        var index = startIndex
        while index < endIndex {
            let endIndex = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            chunks.append(subdata(in: index..<endIndex))
            index = endIndex
        }
        return chunks
    }
}
