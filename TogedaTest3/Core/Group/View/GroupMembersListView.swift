//
//  GroupMembersListView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.01.24.
//

import SwiftUI

struct GroupMembersListView: View {
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    @ObservedObject var groupVM: GroupViewModel
    let userID = UserDefaults.standard.string(forKey: "userId") ?? ""
    
    var clubMember: ClubMember? {
        return groupVM.club.members.first { ClubMember in
            ClubMember.userID == userID
        }
    }
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                
                if groupVM.club.joinRequestUsers.count > 0 {
                    NavigationLink(destination: TestView()){
                        GroupUserRequestTab(clubMember: groupVM.joinRequestUsers)
                    }
                }
                
                ForEach(groupVM.club.members, id:\.userID) { member in
                    NavigationLink(destination: UserProfileView(miniUser: member.user)){
                        HStack{
                            Image(member.user.profileImageUrl[0])
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading){
                                Text(member.user.fullName)
                                    .fontWeight(.semibold)
                                Text(member.status)
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            Button{} label:{
                                Image(systemName: "ellipsis")
                                    .rotationEffect(Angle(degrees: 90))
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
            }
            .padding(.horizontal)
            
        }
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
    
}

struct GroupUserRequestTab: View {
    var clubMember: [MiniUser]
    let size: ImageSize = .medium
    var body: some View {
            HStack{
                if clubMember.count == 1 {
                    Image(clubMember[0].profileImageUrl[0])
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
                        Image(clubMember[0].profileImageUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color("base"), lineWidth: 2)
                            )
                        
                        Image(clubMember[1].profileImageUrl[0])
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
                    Text("View Group Requests.")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    if clubMember.count == 1 {
                        Text("\(clubMember[0].fullName) is waiting approval")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    } else {
                        Text("\(clubMember[0].fullName) & \(clubMember.count) more ")
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
    GroupMembersListView(groupVM: GroupViewModel())
}
