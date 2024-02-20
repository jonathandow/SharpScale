import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var items: [String] = []
    let dbHelper = SQLiteHelper()

    var body: some View {
        NavigationView {
                    List {
                        Section(header: Text("Bluetooth")) {
                            if bluetoothManager.isConnected {
                                Text("Connected to Raspberry Pi")
                            } else {
                                Button("Connect to Raspberry Pi") {
                                    bluetoothManager.connectToRaspberryPi()
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
