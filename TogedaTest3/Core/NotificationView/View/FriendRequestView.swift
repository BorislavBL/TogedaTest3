//
//  FriendRequestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI
import Kingfisher

struct FriendRequestView: View {
    let size: ImageSize = .medium
    var user: Components.Schemas.AlertBodyFriendRequestReceived
    var createDate: Date
    var body: some View {
        VStack {
            NavigationLink(value: SelectionPath.profile(MockMiniUser)){
                HStack(alignment:.top){
                    KFImage(URL(string: user.sender.profilePhotos[0])!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                    
                }
                VStack(alignment:.leading){
                    Text("\(user.sender.firstName) \(user.sender.lastName)")
                        .font(.footnote)
                        .fontWeight(.semibold) +
                    
                    
                    Text(" Sends you a Friend Request. ")
                        .font(.footnote) +
                    
                    Text(formatDateForNotifications(from: createDate))
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
    FriendRequestView(user: mockAlertBodyFriendRequestReceived, createDate: Date())
}
