//
//  BluetoothManager.swift
//  SharpScale
//
//  Created by Jonathan Dow on 2/20/24.
//

import Foundation
import Combine

class BluetoothManager: ObservableObject, BTManagerDelegate {
    private var btManager: BTManager
    @Published var isConnected: Bool = false
    
    init() {
        self.btManager = BTManager()
        self.btManager.delegate = self
        setupBindings()
    }
    
    private func setupBindings() {
        print("Hey")
    }
    
    func didUpdateConnectionStatus(connected: Bool) {
        DispatchQueue.main.async{
            self.isConnected = connected
        }
    }
    
    func connectToRaspberryPi() {
            btManager.centralManager.scanForPeripherals(withServices: [btManager.raspberryPiServiceUUID], options: nil)
        }
    
    
}
