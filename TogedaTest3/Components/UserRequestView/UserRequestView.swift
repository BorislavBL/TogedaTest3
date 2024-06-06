//
//  FriendRequestPageView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI
import Kingfisher

struct UserRequestView: View {
    private let size: ImageSize = .medium
    @Environment(\.dismiss) private var dismiss
    var users: [Components.Schemas.MiniUser] = []

    var body: some View {
        ScrollView{
            LazyVStack(spacing: 16){
                ForEach(users, id: \.id){user in
                    UserRequestComponent(user: user, confirm: {}, delete: {})
                }
                
            }
        }
        .navigationTitle("Friend Requests")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .padding(.top)
        .padding(.horizontal)
    }
}

#Preview {
    UserRequestView()
}
