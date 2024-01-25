//
//  NotificationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false){
            LazyVStack(spacing: 16){
                FriendRequestPage()
                FriendRequestView()
                AddedMemoryView()
                ParticipantsEventReview()
                EventAcceptance()
                GroupAcceptanceView()
                SystemNotificationView()
                EventRequestPage()
                GroupRequestPage()
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
}
