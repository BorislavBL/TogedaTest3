//
//  TogedaTest3App.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.09.23.
//

import SwiftUI
import StripeCore

@main
struct TogedaTest3App: App {
    @StateObject var vm = ContentViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var showToken: Bool = true
    @StateObject var navigationManager = NavigationManager()
    var urlHandler: URLHandler?
    
    init() {
        let navigationManager = NavigationManager()
        self._navigationManager = StateObject(wrappedValue: navigationManager)
        self.urlHandler = URLHandler(navigationManager: navigationManager)
        appDelegate.urlHandler = URLHandler(navigationManager: navigationManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .environmentObject(navigationManager)
                .onAppear(){
                    APIClient.shared.setViewModel(vm)
                }
                .onOpenURL { url in
                    if vm.miniValidation() {
                        let stripeHandled = StripeAPI.handleURLCallback(with: url)
                        if (!stripeHandled) {
                            urlHandler?.handleURL(url)
                        }
                    }
                }
        }
    }
}
