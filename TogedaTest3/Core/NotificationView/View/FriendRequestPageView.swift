//
//  FriendRequestPageView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI

struct FriendRequestPageView: View {
    let size: ImageSize = .medium
    @Environment(\.dismiss) var dismiss
    var users: [MiniUser] = MiniUser.MOCK_MINIUSERS
    var body: some View {
        ScrollView{
            LazyVStack(spacing: 16){
                ForEach(users, id: \.id){user in
                    NavigationLink(destination: UserProfileView(miniUser: user)){
                        HStack(alignment:.top){
                                Image(user.profileImageUrl[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                            
                        }
                        VStack(alignment:.leading){
                            Text(user.fullName)
                                .font(.footnote)
                                .fontWeight(.semibold)
                            
                            
                            HStack(alignment:.center, spacing: 10) {
                                Button {
                                    
                                } label: {
                                    Text("Confirm")
                                        .normalTagTextStyle()
                                        .frame(maxWidth: .infinity)
                                        .normalTagRectangleStyle()
                                }
                                Button {
                                    
                                } label: {
                                    Text("Delete")
                                        .normalTagTextStyle()
                                        .frame(maxWidth: .infinity)
                                        .normalTagRectangleStyle()
                                }
                            }
                        }
                        .multilineTextAlignment(.leading)
                    }
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
    FriendRequestPageView()
}
