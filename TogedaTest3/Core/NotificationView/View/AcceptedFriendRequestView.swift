//
//  AcceptedFriendRequestView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 13.08.24.
//

import SwiftUI
import Kingfisher

struct AcceptedFriendRequestView: View {
    let size: ImageSize = .medium
    var user: Components.Schemas.AlertBodyFriendRequestAccepted
    var createDate: Date
    var body: some View {
        VStack {
            NavigationLink(value: SelectionPath.profile(user.user)){
                HStack(alignment:.center){
                    KFImage(URL(string: user.user.profilePhotos[0])!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                    
                    
                    VStack(alignment:.leading){
                        Text("\(user.user.firstName) \(user.user.lastName)")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        
                        Text("\(user.user.firstName) accepted your friend request! ")
                            .font(.footnote) +
                        
                        Text(formatDateForNotifications(from: createDate))
                            .foregroundStyle(.gray)
                            .font(.footnote)
                    }
                    .multilineTextAlignment(.leading)
                }
            }
            Spacer(minLength: 0)
            
        }
    }
}

#Preview {
    AcceptedFriendRequestView(user: mockAlertBodyFriendRequestAccepted, createDate: Date())
}

