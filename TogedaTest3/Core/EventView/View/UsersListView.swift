//
//  UsersListView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.11.23.
//

import SwiftUI

struct UsersListView: View {
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    var users: [MiniUser]
    var post: Post
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                if post.joinRequests.count > 0 && post.askToJoin{
                    NavigationLink(destination: UserRequestView(users: users)){
                        UserRequestTab(users: users)
                    }
                }
                ForEach(users, id:\.id) { user in
                    NavigationLink(destination: UserProfileView(miniUser: user)){
                        HStack{
                            Image(user.profileImageUrl[0])
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(Circle())
                            
                            
                            Text(user.fullName)
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
    UsersListView(users: MiniUser.MOCK_MINIUSERS, post: Post.MOCK_POSTS[4])
}
