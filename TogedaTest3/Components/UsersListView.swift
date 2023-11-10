//
//  UsersListView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.11.23.
//

import SwiftUI

struct UsersListView: View {
    @Environment(\.dismiss) private var dismiss
    var users: [MiniUser]
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                ForEach(users, id:\.id) { user in
                    NavigationLink(destination: UserProfileView(miniUser: user)){
                        HStack{
                            Image(user.profileImageUrl[0])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                            
                            
                            Text(user.fullname)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 5)
                    }
                }
                
            }
            .padding(.horizontal)
            
        }
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
}

#Preview {
    UsersListView(users: MiniUser.MOCK_MINIUSERS)
}
