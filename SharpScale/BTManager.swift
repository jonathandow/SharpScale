import CoreBluetooth

class BTManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    @Published var connectionStatus: String = "Disconnected"
    private let serviceUUID = CBUUID(string: "180D")
    private var raspberryPiPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
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
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        self.raspberryPiPeripheral = peripheral
        connectionStatus = "Connecting to \(peripheral.name ?? "device")..."
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionStatus = "Connected to \(peripheral.name ?? "Raspberry Pi 5")"
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionStatus = "Failed to connect to \(peripheral.name ?? "device")"
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionStatus = "Disconnected"
        centralManager.connect(peripheral, options: nil)
    }
}
