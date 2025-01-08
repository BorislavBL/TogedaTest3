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
            NavigationLink(value: SelectionPath.userFriendRequestsList){
                HStack(alignment:.center){
                    KFImage(URL(string: user.sender.profilePhotos[0])!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                    
                    
                    VStack(alignment:.leading){
                        Text("\(user.sender.firstName) \(user.sender.lastName)")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("\(user.sender.firstName) sent you a Friend Request. ")
                            .font(.footnote) +
                        
                        Text(formatDateForNotifications(from: createDate))
                            .foregroundStyle(.gray)
                            .font(.footnote)
                        
                    }
                    .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
            }
            
        }
    }
}

#Preview {
    FriendRequestView(user: mockAlertBodyFriendRequestReceived, createDate: Date())
}
