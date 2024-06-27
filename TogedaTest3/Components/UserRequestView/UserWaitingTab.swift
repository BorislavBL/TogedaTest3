//
//  UserWaitingTab.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 11.06.24.
//

import SwiftUI
import Kingfisher

struct UserWaitingTab: View {
    var users: [Components.Schemas.MiniUser]
    let size: ImageSize = .medium
    var body: some View {
            HStack{
                if users.count == 1 {
                    KFImage(URL(string: users[0].profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color("base"), lineWidth: 2)
                        )
                } else if users.count > 0 {
                    ZStack(alignment:.top){
                        KFImage(URL(string: users[0].profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color("base"), lineWidth: 2)
                            )
                        
                        KFImage(URL(string: users[1].profilePhotos[0]))
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
                    Text("View Waiting List.")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    if users.count == 1 {
                        Text("\(users[0].firstName) \(users[0].lastName) is waiting ...")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    } else if users.count > 0  {
                        Text("\(users[0].firstName) \(users[0].lastName) & others")
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
    UserWaitingTab(users: [MockMiniUser])
}
