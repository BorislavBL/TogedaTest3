//
//  FriendRequestPage.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 6.11.23.
//

import SwiftUI

struct FriendRequestPage: View {
    let size: ImageSize = .medium
    var users: [MiniUser] = MiniUser.MOCK_MINIUSERS
    var body: some View {
        VStack{
            NavigationLink(destination: UserRequestView(users: users)){
                HStack{
                    ZStack(alignment:.top){
                       
                            Image(users[0].profilePhotos[0])
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color("base"), lineWidth: 2)
                                )
                                
                            Image(users[1].profilePhotos[0])
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color("base"), lineWidth: 2)
                                )
                                .offset(x:size.dimension/2)

                    }
                    .padding(.trailing, size.dimension/2)
                    
                    VStack(alignment: .leading){
                        Text("View Friend Requests.")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("\(users[0].fullName) & \(users.count) more ")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                    Spacer(minLength: 0)
                    
                    Image(systemName: "chevron.right")
                }
            }
        }
    }
}

#Preview {
    FriendRequestPage()
}
