//
//  GroupMembersListView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 4.01.24.
//

import SwiftUI
import Kingfisher

struct GroupMembersListView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    @StateObject var groupVM = GroupViewModel()
    
    @State var isLoading = false
    
    var club: Components.Schemas.ClubDto
    @State var showUserOptions = false
    @State var selectedExtendedUser: Components.Schemas.ExtendedMiniUserForClub?
    @State var Init: Bool = true
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                
                if club.askToJoin && club.currentUserRole == .ADMIN && groupVM.joinRequestParticipantsList.count > 0 {
                    NavigationLink(value: SelectionPath.clubJoinRequests(club)){
                        UserRequestTab(users: groupVM.joinRequestParticipantsList)
                    }
                }
                
                ForEach(groupVM.clubMembers, id:\.user.id) { user in
                    HStack{
                        NavigationLink(value: SelectionPath.profile(user.user)){
                            HStack{
                                KFImage(URL(string: user.user.profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading){
                                    Text("\(user.user.firstName) \(user.user.lastName)")
                                        .fontWeight(.semibold)
                                    if user._type == .ADMIN {
                                        Text(user._type.rawValue.capitalized)
                                            .foregroundColor(.gray)
                                            .fontWeight(.semibold)
                                            .font(.footnote)
                                    }
                                    
                                }
                                
                                Spacer()
                                
                                Button{
                                    showUserOptions = true
                                    selectedExtendedUser = user
                                } label:{
                                    Image(systemName: "ellipsis")
                                        .rotationEffect(.degrees(90))
                                }
                            }
                            
                        }
                        
                        
                        
                    }
                    .padding(.vertical, 5)
                }
                
                if isLoading{
                    ProgressView()
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !groupVM.membersLastPage {
                            isLoading = true
                            
                            Task{
                                try await groupVM.fetchClubMembers(clubId: club.id)
                                isLoading = false
                                
                            }
                        }
                    }
            }
            .padding(.horizontal)
            
        }
        .onAppear(){
            Task{
                do{
                    if Init {
                        try await groupVM.fetchClubMembers(clubId: club.id)
                        Init = false
                    }
                    
                    if club.askToJoin {
                        groupVM.joinRequestParticipantsList = []
                        groupVM.joinRequestParticipantsPage = 0
                        try await groupVM.fetchClubJoinRequests(clubId: club.id)
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .sheet(isPresented: $showUserOptions, content: {

                List {
                    if let extendedUser = selectedExtendedUser {
                        if let user = userVM.currentUser, club.owner.id == user.id{
                            if extendedUser._type == .MEMBER  {
                                Button("Make an Admin") {
                                    Task{
                                        if try await APIClient.shared.addAdminToClub(clubId: club.id, userId: extendedUser.user.id) {
                                            showUserOptions = false
                                            
                                            if let index = groupVM.clubMembers.firstIndex(where: { $0.user.id == extendedUser.user.id }) {
                                                groupVM.clubMembers[index]._type = .ADMIN
                                            }
                                        }
                                    }
                                }
                            } else if extendedUser._type == .ADMIN {
                                Button("Remove as an Admin") {
                                    Task{
                                        if try await APIClient.shared.removeAdminRoleForClub(clubId: club.id, userId: extendedUser.user.id) {
                                            
                                            if let index = groupVM.clubMembers.firstIndex(where: { $0.user.id == extendedUser.user.id }) {
                                                groupVM.clubMembers[index]._type = .MEMBER
                                            }
                                            
                                            showUserOptions = false
                                        }
                                    }
                                }
                            }
                        }
                        if club.currentUserStatus == .PARTICIPATING {
                            Button("Report") {
                                
                            }
                        }
                        
                        if club.currentUserRole == .ADMIN && extendedUser._type != .ADMIN {
                            Button("Remove") {
                                Task{
                                    if try await APIClient.shared.removeClubMemeber(clubId: club.id, userId: extendedUser.user.id) {
                                        
                                        if let index = groupVM.clubMembers.firstIndex(where: { $0.user.id == extendedUser.user.id }) {
                                            groupVM.clubMembers.remove(at: index)
                                        }
                                        
                                        showUserOptions = false
                                    }
                                }
                            }
                        }
                        
                    } else {
                        Text("No extended user")
                    }
                }
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
                .scrollDisabled(true)
            
        })
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
    
}

#Preview {
    GroupMembersListView(groupVM: GroupViewModel(), club: MockClub)
        .environmentObject(UserViewModel())
}
