//
//  TogedaTest3App.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI

@main
struct TogedaTest3App: App {
    @StateObject var vm = ContentViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var CognitoClient
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .onAppear(){
                    APIClient.shared.setViewModel(vm)
                }
        }
    }
}
