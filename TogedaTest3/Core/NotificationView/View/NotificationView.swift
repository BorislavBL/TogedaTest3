//
//  NotificationView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI

enum ImageSize {
    case small
    case medium
    case large
    
    var dimension: CGFloat {
        switch self {
        case .small:
            return 40
        case .medium:
            return 60
        case .large:
            return 120
        }
    }
}

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false){
            LazyVStack(spacing: 16){
                FriendRequestPage()
                FriendRequestView()
                AddedMemoryView()
                ParticipantsEventReview()
            }
            .padding(.horizontal)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .padding(.top)
    }
}


#Preview {
    NotificationView()
}
