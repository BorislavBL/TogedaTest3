//
//  UsersRequestTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 12.01.24.
//

import SwiftUI

struct UserRequestTab: View {
    var users: [MiniUser]
    let size: ImageSize = .medium
    var body: some View {
            HStack{
                if users.count == 1 {
                    Image(users[0].profilePhotos[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color("base"), lineWidth: 2)
                        )
                } else {
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
                }
                
                VStack(alignment: .leading){
                    Text("View Join Requests.")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    if users.count == 1 {
                        Text("\(users[0].fullName) is waiting approval")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    } else {
                        Text("\(users[0].fullName) & \(users.count) more ")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                }
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.right")
            }
    }
}

#Preview {
    UserRequestTab(users: MiniUser.MOCK_MINIUSERS)
}
