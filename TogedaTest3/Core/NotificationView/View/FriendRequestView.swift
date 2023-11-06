//
//  FriendRequestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI

struct FriendRequestView: View {
    let size: ImageSize = .medium
    var user: MiniUser = MiniUser.MOCK_MINIUSERS[0]
    var body: some View {
        VStack {
            NavigationLink(destination: UserProfileView(miniUser: user)){
                HStack(alignment:.top){
                    if let images = user.profileImageUrl {
                        Image(images[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .frame(width: 75, height: 75)
                    }
                    
                }
                VStack(alignment:.leading){
                    Text(user.fullname)
                        .font(.footnote)
                        .fontWeight(.semibold) +
                    
                    
                    Text(" Sends you a Friend Request.")
                        .font(.footnote) +
                    
                    Text(" 1 min ago")
                        .foregroundStyle(.gray)
                        .font(.footnote)
                    
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

#Preview {
    FriendRequestView()
}
