//
//  GroupMembersView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI

struct GroupMembersView: View {
    @ObservedObject var groupVM: GroupViewModel
    var userID: String
    
    var imgSize: ImageSize = .medium
    var body: some View {
        VStack (alignment: .leading) {
            HStack{
                HStack{
                    Text("Members")
                        .font(.body)
                        .fontWeight(.bold)
                    
                    if groupVM.club.members.count > 0 {
                        Text("\(groupVM.club.members.count)")
                            .foregroundStyle(.gray)
                    }
                }
                
                Spacer()
                
                NavigationLink(destination: GroupMembersListView(groupVM: groupVM)) {
                    Text("View All")
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false){
                LazyHStack{
                    ForEach(groupVM.club.members.indices, id: \.self){ index in
                        if index < 10 {
                            NavigationLink(destination: UserProfileView(miniUser: MockMiniUser)) {
                                Image(groupVM.club.members[index].user.profilePhotos[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imgSize.dimension, height: imgSize.dimension)
                                    .background(.gray)
                                    .clipShape(Circle())
                            }
                        } else if index == 10 {
                            ZStack{
                                Image(groupVM.club.members[index].user.profilePhotos[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imgSize.dimension, height: imgSize.dimension)
                                    .background(.gray)
                                    .clipShape(Circle())
                                
                                Circle()
                                    .frame(width: imgSize.dimension, height: imgSize.dimension)
                                    .foregroundStyle(.black)
                                    .opacity(0.5)
                                
                                Text(" + \(groupVM.club.members.count - 10)")
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.leading)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical)
        .background(.bar)
        .cornerRadius(10)
    }
}

#Preview {
    GroupMembersView(groupVM: GroupViewModel(), userID: MiniUser.MOCK_MINIUSERS[0].id)
}
