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
    @State var showUserOptions = false
    @State var selectedOption: String?
    @State var selectedUser: MiniUser?
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                if post.joinRequests.count > 0 && post.askToJoin{
                    NavigationLink(value: SelectionPath.userRequests(users: users)){
                        UserRequestTab(users: users)
                    }
                }
                ForEach(users, id:\.id) { user in
                    HStack{
                        NavigationLink(value: SelectionPath.profile(MockMiniUser)){
                            HStack{
                                Image(user.profilePhotos[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                                
                                
                                Text(user.fullName)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                            }
                            
                        }
                        Button{
                            showUserOptions = true
                            selectedUser = user
                        } label:{
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                        }
                    }
                    .padding(.vertical, 5)
                }
                
            }
            .padding(.horizontal)
            
        }
        .sheet(isPresented: $showUserOptions, content: {
            List {
                Button("Make a Co-Host") {
                    selectedOption = "Co-Host"
                }

                Button("Remove") {
                    selectedOption = "Remove"
                }
            }
            .presentationDetents([.fraction(0.20)])
            .presentationDragIndicator(.visible)
        })
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
