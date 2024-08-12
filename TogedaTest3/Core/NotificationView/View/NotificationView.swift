//
//  NotificationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: WebSocketManager
    @EnvironmentObject var navManager: NavigationManager
    @State var isLoading = false
    
    var body: some View {
        ScrollView(showsIndicators: false){
            LazyVStack(spacing: 16){
                ForEach(vm.notificationsList, id: \.id) { notification in
                    // Handle different cases of alertBody
                    if let not = notification.alertBodyAcceptedJoinRequest{
                        switch not.forType {
                        case .CLUB:
                            if let club = not.club{
                                GroupAcceptanceView(club: club, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                            }
                        case .POST:
                            if let post = not.post{
                                EventAcceptance(post: post, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                            }
                        case .none:
                            EmptyView()
                        }
                    } else if let not = notification.alertBodyReceivedJoinRequest{
                        switch not.forType {
                        case .POST:
                            if let post = not.post{
                                EventRequestPage(post: post, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                            }
                        case .CLUB:
                            if let club = not.club{
                                GroupRequestPage(club: club, createDate: notification.createdDate, alertBody: not, selectionPath: $navManager.selectionPath)
                            }
                        case .none:
                            EmptyView()
                        }
                    } else if let not = notification.alertBodyFriendRequestReceived{
                        FriendRequestView(user: not, createDate: notification.createdDate)
                    } else if let not = notification.alertBodyReviewEndedPost {
                        ParticipantsEventReview(alertBody: not, createDate: notification.createdDate, selectionPath: $navManager.selectionPath)
                    } else if let not = notification.alertBodyPostHasStarted {
                        EventHasStartedView(createDate: notification.createdDate, alertBody: not, selectionPath:  $navManager.selectionPath)
                    }
                }
//                FriendRequestPage()
//                FriendRequestView()
//                AddedMemoryView()
//                SystemNotificationView()
                
                if isLoading {
                    ProgressView() // Show spinner while loading
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !vm.lastPage{
                            isLoading = true
                            Task{
                                try await vm.fetchInitialNotification(){ success in
                                    isLoading = false
                                }
                            }
                        }
                    }
                
            }
            .padding()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
                .navButton3()
        }
                            
                            
        )
        .swipeBack()
        
    }
}


#Preview {
    NotificationView()
        .environmentObject(WebSocketManager())
        .environmentObject(NavigationManager())
}
