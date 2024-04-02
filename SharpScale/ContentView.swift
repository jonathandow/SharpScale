import SwiftUI

struct ContentView: View {
    @State private var items: [String] = []
    let dbHelper = SQLiteHelper()

    var body: some View {
        NavigationView {
                    List {
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
                        Section(header: Text("Bluetooth Devices")) {
                            NavigationLink(destination: BluetoothView()) {
                                Text("Connect to Bluetooth Device")
                            }
                        }
                    }
                    .navigationTitle("Main Menu")
        }
    }
}


struct BluetoothView: View {
    @ObservedObject private var bluetoothManager = BTManager()
    @State private var isConnecting: Bool = false
    @State private var connectionStatus: String = ""
    let dbHelper = SQLiteHelper()
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Bluetooth Devices")) {
                    ForEach(bluetoothManager.peripherals.indices, id: \.self) { index in
                        HStack {
                            Text(bluetoothManager.peripheralNames[index])
                            Spacer()
                            if isConnecting && bluetoothManager.currentPeripheralIndex == index {
                                Text("Connecting...")
                                    .foregroundColor(.gray)
                            } else {
                                Button(action: {
                                    isConnecting = true
                                    let peripheral = bluetoothManager.peripherals[index]
                                    bluetoothManager.currentPeripheralIndex = index
                                    bluetoothManager.connectToDevice(peripheral: peripheral)
                                }) {
                                    Text("Connect")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Bluetooth Devices")
        }
    }
}
