//
//  NetworkManager.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 8.11.23.
//

import SwiftUI
import Network

class NetworkManager: ObservableObject {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkManager")
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                withAnimation {
                    self.isConnected = path.status == .satisfied
                }
            }
        }
        
        monitor.start(queue: queue)
    }
}
