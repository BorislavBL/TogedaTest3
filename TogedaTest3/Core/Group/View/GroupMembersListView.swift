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
                
                if groupVM.club.joinRequestUsers.count > 0 && groupVM.club.askToJoin {
                    NavigationLink(destination: UserRequestView(users: groupVM.joinRequestUsers)){
                        UserRequestTab(users: groupVM.joinRequestUsers)
                    }
                }
                
                ForEach(groupVM.club.members, id:\.userID) { member in
                    NavigationLink(destination: UserProfileView(miniUser: member.user)){
                        HStack{
                            Image(member.user.profilePhotos[0])
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

#Preview {
    GroupMembersListView(groupVM: GroupViewModel())
}
