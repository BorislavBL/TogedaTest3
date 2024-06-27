//
//  NotificationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: NotificationsViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false){
            LazyVStack(spacing: 16){
                ForEach(vm.notificationsList, id: \.id) { notification in
                    // Handle different cases of alertBody
                    if let not = notification.alertBodyAcceptedJoinRequest{
                        switch not.forType {
                        case .CLUB:
                            GroupAcceptanceView(createDate: notification.createdDate, alertBody: not)
                        case .POST:
                            EventAcceptance(createDate: notification.createdDate, alertBody: not)
                        }
                    } else if let not = notification.alertBodyReceivedJoinRequest{
                        switch not.forType {
                        case .POST:
                            EventRequestPage(createDate: notification.createdDate, alertBody: not)
                        case .CLUB:
                            GroupRequestPage(createDate: notification.createdDate, alertBody: not)
                        }
                    } else if let not = notification.alertBodyFriendRequestReceived{
                        FriendRequestView(user: not, createDate: notification.createdDate)
                    } else if let not = notification.alertBodyReviewEndedPost{
                        ParticipantsEventReview(alertBody: not, createDate: notification.createdDate)
                    }
                }
//                FriendRequestPage()
//                FriendRequestView()
//                AddedMemoryView()
//                ParticipantsEventReview()
//                SystemNotificationView()
                
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
        
    }
}


#Preview {
    NotificationView()
        .environmentObject(NotificationsViewModel())
}
