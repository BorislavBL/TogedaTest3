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
    @StateObject var networkManager = NetworkManager()
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
                .environmentObject(networkManager)
                .onAppear(){
                    APIClient.shared.setViewModel(vm)
                }
                .onOpenURL { url in
                    print("HEEEEEEREEEEE",url)
                    if vm.initialSetupDone {
                        let stripeHandled = StripeAPI.handleURLCallback(with: url)
                        if (!stripeHandled) {
                            urlHandler?.handleURL(url)
                            print("123")
                            let URL = urlHandler?.transformURL(url: url)
                            if let url = URL, url.host == "resetUser" {
                                vm.resetCurrentUser = true
                            }
                        }
                        
                    }
                    else {
                        // If session is invalid, store the URL for later
                        print("Pending URL")
                        vm.pendingURL = url
                    }
                }
                .onChange(of: vm.initialSetupDone) {
                    if let url = vm.pendingURL, vm.initialSetupDone{
                        urlHandler?.handleURL(url)
                        let URL = urlHandler?.transformURL(url: url)
                        if let url = URL, url.host == "resetUser" {
                            vm.resetCurrentUser = true
                        }
                        vm.pendingURL = nil
                    }
                }
                .onChange(of: appDelegate.deeplink) {
                    print("Deep link activated here 1")
                    if let link = appDelegate.deeplink {
                        print("Deep link activated here 2")
                        if vm.initialSetupDone {
                            print("Deep link activated here 3")
                            urlHandler?.handleURL(link)
                            let URL = urlHandler?.transformURL(url: link)
                            if let url = URL, url.host == "resetUser" {
                                vm.resetCurrentUser = true
                            }
                        
                            appDelegate.deeplink = nil
                        } else {
                            // If session is invalid, store the URL for later
                            print("Pending URLLLLLLLLLLLLLLLLLLLLL")
                            vm.pendingURL = link
                        }
                    }
                }
        }
    }
}
