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
    @ObservedObject var bluetoothManager = BTManager()

    var body: some View {
        NavigationView {
            VStack {
                Text("Raspberry Pi 5 Connection Status")
                    .font(.headline)
                    .padding()

                Text(bluetoothManager.connectionStatus)
                    .font(.body)
                    .foregroundColor(bluetoothManager.connectionStatus.contains("Connected") ? .green : .red)
                    .padding()

                Spacer()
                
                Button("Update Raspberry Pi Database") {
                    bluetoothManager.initiateDatabaseUpdate()
                }
                .disabled(!bluetoothManager.isConnected)
            }
            .navigationBarTitle("Bluetooth Connection")
        }
    }
}

struct BluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothView()
    }
}
