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
            NavigationLink(value: SelectionPath.profile(MockMiniUser)){
                HStack(alignment:.top){
                        Image(user.profilePhotos[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                    
                }
                VStack(alignment:.leading){
                    Text(user.fullName)
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
