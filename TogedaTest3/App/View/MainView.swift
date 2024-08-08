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
    @StateObject var webSocketManager = WebSocketManager()
    
    private var urlHandler: URLHandler?
    
    init() {
        let navigationManager = NavigationManager()
        self._navigationManager = StateObject(wrappedValue: navigationManager)
        self.urlHandler = URLHandler(navigationManager: navigationManager)
    }    
    
    var body: some View {
        MainTabView()
            .fullScreenCover(isPresented: $navigationManager.isPresenting) {
                CreateEventView()
            }
            .environmentObject(postsViewModel)
            .environmentObject(clubsViewModel)
            .environmentObject(userViewModel)
            .environmentObject(locationManager)
            .environmentObject(navigationManager)
            .environmentObject(webSocketManager)
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
                    try await allInitialFetches()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                print("Diappear")
                webSocketManager.disconnect()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                print("opened once again")
                
                Task{
                    try await fetchOnDidBecomeActive()
                }
                
            }
            .onOpenURL { url in
                let stripeHandled = StripeAPI.handleURLCallback(with: url)
                if (!stripeHandled) {
                    urlHandler?.handleURL(url)
                }
            }
            .onChange(of: userViewModel.currentUser) {
                webSocketManager.currentUserId = userViewModel.currentUser?.id
            }
            .onChange(of: webSocketManager.newNotification) { oldValue, newValue in
                if let notification = newValue{
                    postsViewModel.postUpdateOnNewNotification(notification: notification)
                    clubsViewModel.clubUpdateOnNewNotification(notification: notification)
                }
            }
    }
    
    func fetchOnDidBecomeActive() async throws{
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    if let chatRoomsResponse = try await APIClient.shared.updateChatRooms(latestDate: webSocketManager.allChatRooms.count > 0 ? webSocketManager.allChatRooms[0].latestMessageTimestamp : Date()) {
                        print("Messages triggered")
                        DispatchQueue.main.async {
                            webSocketManager.chatRoomsCheck(chatRooms: chatRoomsResponse)
                        }
                        
                    }
                } catch {
                    // Handle the error if needed
                    print("Error updating chat rooms: \(error)")
                }
            }
            
            group.addTask {
                do {
                    if let notificationsResponse = try await APIClient.shared.updateNotifications(lastTimestamp: webSocketManager.notificationsList.count > 0 ? webSocketManager.notificationsList[0].createdDate : Date()) {
                        print("Notifications triggered")
                        DispatchQueue.main.async {
                            webSocketManager.notificationsCheck(notifications: notificationsResponse)
                        }

                    }
                } catch {
                    // Handle the error if needed
                    print("Error updating notifications: \(error)")
                }
            }
            
            // Wait for both tasks to complete
            await group.waitForAll()
            
            // After both tasks are complete, trigger the connect method
            webSocketManager.connect()
        }
    }
    
    func allInitialFetches() async throws {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await userViewModel.fetchCurrentUser()
                    print("End user fetch")
                } catch {
                    // Handle the error if needed
                    print("Error fetching data: \(error)")
                }
            }
            
            group.addTask {
                do {
                    try await webSocketManager.fetchInitialNotification { success in

                    }
                } catch {
                    print(error)
                }
            }
            
            group.addTask {
                do {
                    try await webSocketManager.getAllChats()
                } catch {
                    print(error)
                }
            }
            
        }
    }
}



#Preview {
    MainView()
}
