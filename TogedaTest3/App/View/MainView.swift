//
//  MainView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 7.05.24.
//

import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
import StripeCore

struct MainView: View {
    @StateObject var postsViewModel = PostsViewModel()
    @StateObject var clubsViewModel = ClubsViewModel()
    @StateObject var userViewModel = UserViewModel()
    @StateObject var navigationManager = NavigationManager()
    @StateObject var locationManager = LocationManager()
    @StateObject var notificationsManager = NotificationsManager()
    @StateObject var notificationsViewModel = NotificationsViewModel()
    
    private var urlHandler: URLHandler?
    
    init() {
        let navigationManager = NavigationManager()
        self._navigationManager = StateObject(wrappedValue: navigationManager)
        self.urlHandler = URLHandler(navigationManager: navigationManager)
    }    
    
    var body: some View {
        MainTabView()
            .environmentObject(postsViewModel)
            .environmentObject(clubsViewModel)
            .environmentObject(userViewModel)
            .environmentObject(locationManager)
            .environmentObject(navigationManager)
            .environmentObject(notificationsViewModel)
            .onChange(of: locationManager.authorizationStatus) {
                if locationManager.authorizationStatus == .authorizedWhenInUse {
                    NotificationsManager.shared.registerForPushNotifications()
                }
            }
            .onAppear() {
                print("appeared")
                if locationManager.authorizationStatus == .authorizedWhenInUse {
                    NotificationsManager.shared.registerForPushNotifications()
                }
                NotificationsManager.shared.setupAuthStatus()
                Task{
                    try await notificationsViewModel.fetchInitialNotification{ success in
                        Task{
                            if success{
                                try await notificationsViewModel.fetchPollNotification()
                            }
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                print("Diappear")
                notificationsViewModel.notificationPoolingActivated = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                print("StartPooling")
                notificationsViewModel.notificationPoolingActivated = true
                Task{
                    try await notificationsViewModel.fetchPollNotification()
                }
            }
            .onOpenURL { url in
                let stripeHandled = StripeAPI.handleURLCallback(with: url)
                if (!stripeHandled) {
                    urlHandler?.handleURL(url)
                }
            }
    }
}



#Preview {
    MainView()
}
