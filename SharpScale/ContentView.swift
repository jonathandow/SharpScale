import SwiftUI
import OSLog

struct ContentView: View {
    @StateObject private var bluetoothViewModel: BluetoothViewModel
    private let logger = Logger(subsystem: "com.sharpscale", category: "ContentView")
    init() {
        let btManager = BTManager()
        _bluetoothViewModel = StateObject(wrappedValue: BluetoothViewModel(btManager: btManager))
        self.logger.log("ContentView Initialized")
    }
    @State private var items: [String] = []
    let dbHelper = SQLiteHelper()

    var body: some View {
        NavigationView {
                    List {
                        Section(header: Text("Bluetooth")) {
                            if bluetoothViewModel.isConnected {
                                Text("Connected to Raspberry Pi")

                            } else {
                                Button("Connect to Raspberry Pi") {
                                    bluetoothViewModel.startConnectionProcess()
                                }
                                
                            }
                        }
                        Section(header: Text("Recipes")) {
                            NavigationLink(destination: RecipeView()) {
                                Text("Manage Recipes")
                            }
                        }

                        Section(header: Text("Ingredients")) {
                            NavigationLink(destination: IngredientView()) {
                                Text("Manage Ingredients")
                            }
                        }
                    }
                    .navigationTitle("Main Menu")
        }
    }
}


class BluetoothViewModel: ObservableObject, BTManagerDelegate {
    private let logger = Logger(subsystem: "com.sharpscale", category: "BluetoothViewModel")
    @Published var isConnected = false
    private var btManager: BTManager
    
    init(btManager: BTManager) {
        self.btManager = btManager
        self.btManager.delegate = self
        self.logger.log("BluetoothViewModel Initialized")
    }
    
    func didUpdateConnectionStatus(connected: Bool) {
        DispatchQueue.main.async{
            self.isConnected = connected
            self.logger.info("ConnectionStatus Updated:  \(connected, privacy: .public)")
        }
    }
    
    func startConnectionProcess() {
        btManager.startConnectionProcess()
        self.logger.log("btManager Connection Process Begin")
    }
}
