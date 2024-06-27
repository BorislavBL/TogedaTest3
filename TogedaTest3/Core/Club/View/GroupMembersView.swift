//
//  GroupMembersView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.01.24.
//

import SwiftUI
import Kingfisher

struct GroupMembersView: View {
    var club: Components.Schemas.ClubDto
    @ObservedObject var groupVM: GroupViewModel
    
    var imgSize: ImageSize = .medium
    var body: some View {
        VStack (alignment: .leading) {
            HStack{
                HStack{
                    Text("Members")
                        .font(.body)
                        .fontWeight(.bold)
                    
                    
                    Text("\(groupVM.membersCount)")
                        .foregroundStyle(.gray)
                    
                }
                
                Spacer()
                
                NavigationLink(value: SelectionPath.clubMemersList(club)) {
                    Text("View All")
                        .fontWeight(.semibold)
                }
            }
            .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false){
                LazyHStack{
                    ForEach(groupVM.clubMembers.indices, id: \.self){ index in
                        if index < 10 {
                            NavigationLink(value: SelectionPath.profile(groupVM.clubMembers[index].user)) {
                                KFImage(URL(string: groupVM.clubMembers[index].user.profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imgSize.dimension, height: imgSize.dimension)
                                    .background(.gray)
                                    .clipShape(Circle())
                            }
                        } else if index == 10 {
                            ZStack{
                                KFImage(URL(string:groupVM.clubMembers[index].user.profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imgSize.dimension, height: imgSize.dimension)
                                    .background(.gray)
                                    .clipShape(Circle())
                                
                                Circle()
                                    .frame(width: imgSize.dimension, height: imgSize.dimension)
                                    .foregroundStyle(.black)
                                    .opacity(0.5)
                                
                                Text(" + \(club.membersCount - 10)")
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
    GroupMembersView(club: MockClub, groupVM: GroupViewModel())
}
