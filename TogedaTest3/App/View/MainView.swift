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
    @EnvironmentObject var vm: ContentViewModel
    @StateObject var postsViewModel = PostsViewModel()
    @StateObject var activityViewModel = ActivityViewModel()
    @StateObject var clubsViewModel = ClubsViewModel()
    @StateObject var userViewModel = UserViewModel()
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject var locationManager = LocationManager()
    @StateObject var notificationsManager = NotificationsManager()
    @StateObject var webSocketManager = WebSocketManager()
    
    @State var setDateOnLeave = Date()

    var body: some View {
        MainTabView()
            .overlay {
                if userViewModel.showStripeWarrning {
                    FullScreenWarningMessageView(
                        isActive: $userViewModel.showStripeWarrning,
                        icon: nil,
                        image: Image(systemName: "creditcard.trianglebadge.exclamationmark.fill"),
                        title: "Action Required",
                        description: "You have active paid events, but attendees can’t join until your Stripe onboarding is complete—please finish setting up your account to start receiving payments.",
                        buttonName: "Go To Stripe",
                        action: {
                            if let url = URL(string: "https://dashboard.stripe.com/dashboard") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        },
                        isCancelButton: true)
                }
            }
            .overlay {
                if postsViewModel.showInstaOverlay{
                    InstagramOverlay(isActive: $postsViewModel.showInstaOverlay, post: postsViewModel.clickedPost)
                }
            }
            .overlay {
                if let user = userViewModel.currentUser, userViewModel.showInstaOverlay{
                    InstagramProfileOverlay(isActive: $userViewModel.showInstaOverlay, user: user)
                }
            }
            .fullScreenCover(isPresented: $navigationManager.isPresentingEvent) {
                CreateEventView()
            }
            .environmentObject(postsViewModel)
            .environmentObject(activityViewModel)
            .environmentObject(clubsViewModel)
            .environmentObject(userViewModel)
            .environmentObject(locationManager)
            .environmentObject(navigationManager)
            .environmentObject(webSocketManager)
            .onChange(of: locationManager.authorizationStatus) {
                if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                    NotificationsManager.shared.registerForPushNotifications()
                }
            }
            .onAppear() {
                if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways{
                    NotificationsManager.shared.registerForPushNotifications()
                }
                NotificationsManager.shared.setupAuthStatus()
                Task{
                    try await allInitialFetches()
                }
            }
            .onDisappear(){
                Task {
                    do {
                        if let _  = try await APIClient.shared.setUserActivityStatus(status: .OFFLINE) {
                            
                        }
                    } catch {
                        print(error)
                    }
                    
                }
                vm.handleAppDidEnterBackground()
                setDateOnLeave = Date()
                webSocketManager.disconnect()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                print("Diappear")
                Task {
                    
                    do {
                        if let _  = try await APIClient.shared.setUserActivityStatus(status: .OFFLINE) {
                            
                        }
                    } catch {
                        print(error)
                    }
                    
                }
                vm.handleAppDidEnterBackground()
                setDateOnLeave = Date()
                webSocketManager.disconnect()
                vm.initialSetupDone = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                print("opened once again")
                print(Date().timeIntervalSince(setDateOnLeave))
                
                Task{
                    try await fetchOnDidBecomeActive()
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
            .onChange(of: vm.sessionCount) { oldValue, newValue in
                print("\(vm.sessionCount) <<<<<<<<<<<<>>>>>>>>>")
                webSocketManager.reconnectWithNewToken()
            }
            .onChange(of: vm.resetCurrentUser) { oldValue, newValue in
                if newValue{
                    Task{
                        try await userViewModel.fetchCurrentUser()
                        vm.resetCurrentUser = false
                    }
                }
            }
    }
    
    func fetchOnDidBecomeActive() async throws{
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await vm.validateTokensAndCheckState()
            }
            
            group.addTask {
                do {
                    if let chatRoomsResponse = try await APIClient.shared.updateChatRooms(latestDate: webSocketManager.allChatRooms.count > 0 ? webSocketManager.allChatRooms[0].latestMessageTimestamp : setDateOnLeave) {
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
                    try await webSocketManager.unreadNotifications()
                } catch {
                    print(error)
                }
            }
            
            group.addTask {
                do {
                    try await webSocketManager.getUnreadMessagesCount()
                } catch {
                    print(error)
                }
            }
            
            group.addTask {
                do {
                    if let notificationsResponse = try await APIClient.shared.updateNotifications(lastTimestamp: webSocketManager.notificationsList.count > 0 ? webSocketManager.notificationsList[0].createdDate : setDateOnLeave) {
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
            
            group.addTask {
                do {
                    if let _  = try await APIClient.shared.setUserActivityStatus(status: .ONLINE) {
                        
                    }
                } catch {
                    print(error)
                }
            }
            
            group.addTask {
                do {
                    try await webSocketManager.unreadNotifications()
                } catch {
                    print(error)
                }
            }
            
            group.addTask {
                do {
                    if let user = await userViewModel.currentUser, let accountId = user.stripeAccountId {
                        try await userViewModel.checkForStripeWarning(accountId: accountId)
                    }
                } catch {
                    print(error)
                }
            }
            
            if Date().timeIntervalSince(setDateOnLeave) > 10 * 60 {
                if let location = locationManager.getUserLocationCords() {
                    postsViewModel.lat = location.coordinate.latitude
                    postsViewModel.long = location.coordinate.longitude
                    postsViewModel.state = .loading
                    postsViewModel.feedPosts = []
                    postsViewModel.lastPage = true
                    postsViewModel.page = 0
                    
                    clubsViewModel.lat = location.coordinate.latitude
                    clubsViewModel.long = location.coordinate.longitude
                    clubsViewModel.state = .loading
                    clubsViewModel.feedClubs = []
                    clubsViewModel.lastPage = true
                    clubsViewModel.page = 0
                    group.addTask {
                        do {
                            try await postsViewModel.fetchPosts()
                        } catch {
                            print(error)
                        }
                    }
                    group.addTask {
                        do {
                            try await clubsViewModel.fetchClubs()
                        } catch {
                            print(error)
                        }
                    }
                    
                }
            }
            
            // Wait for both tasks to complete
            await group.waitForAll()
            DispatchQueue.main.async {
                vm.initialSetupDone = true
                if webSocketManager.swiftStomp.connectionStatus == .socketDisconnected {
                    webSocketManager.reconnectWithNewToken()
                }
            }
            
            // After both tasks are complete, trigger the connect method
//            webSocketManager.recconect()
        }
    }
    
    func allInitialFetches() async throws {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await userViewModel.retryFetchUser()
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
                    try await webSocketManager.unreadNotifications()
                } catch {
                    print(error)
                }
            }
            
            group.addTask {
                do {
                    try await webSocketManager.getUnreadMessagesCount()
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
            
            group.addTask {
                do {
                    if let _  = try await APIClient.shared.setUserActivityStatus(status: .ONLINE) {
                        
                    }
                } catch {
                    print(error)
                }
            }
            
             //Wait for both tasks to complete
            await group.waitForAll()
            DispatchQueue.main.async {
                vm.initialSetupDone = true
            }

            
        }
    }
}



#Preview {
    MainView()
        .environmentObject(NavigationManager())
        .environmentObject(ContentViewModel())
}
