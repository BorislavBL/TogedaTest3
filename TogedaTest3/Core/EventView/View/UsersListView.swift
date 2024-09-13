//
//  UsersListView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 2.11.23.
//

import SwiftUI
import Kingfisher

struct UsersListView: View {
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    @StateObject var eventVM = EventViewModel()
    
    @State var isLoading = false
    
    var post: Components.Schemas.PostResponseDto
    @State var showReportSheet = false
    @State var selectedExtendedUser: Components.Schemas.ExtendedMiniUser?
    @State var Init: Bool = true
    
    @EnvironmentObject var userVm: UserViewModel
    
    var joinRequestParticipantsAsMiniUsers: [Components.Schemas.MiniUser] {
        return eventVM.joinRequestParticipantsList.map { data in
            return data.miniUser
        }
    }
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                if post.status != .HAS_ENDED && post.askToJoin && eventVM.joinRequestParticipantsList.count > 0 && (post.currentUserRole == .CO_HOST || post.currentUserRole == .HOST){
                    NavigationLink(value: SelectionPath.eventUserJoinRequests(post: post)){
                        UserRequestTab(users: joinRequestParticipantsAsMiniUsers)
                    }
                }
                
                
                if post.status != .HAS_ENDED && !post.askToJoin && eventVM.waitingList.count > 0 && (post.currentUserRole == .CO_HOST || post.currentUserRole == .HOST){
                    NavigationLink(value: SelectionPath.eventWaitingList(post)){
                        UserWaitingTab(users: eventVM.waitingList)
                    }
                }
                
                ForEach(eventVM.participantsList, id:\.user.id) { user in
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
                                    if user._type == .CO_HOST || user._type == .HOST {
                                        Text(user._type.rawValue.capitalized)
                                            .foregroundColor(.gray)
                                            .fontWeight(.semibold)
                                            .font(.footnote)
                                    }
                                    
                                }
                                
                                
                            }
                        }
                        
                        Spacer()
                        
                        if post.currentUserStatus == .PARTICIPATING {
                            HStack{
                                if let currentUser = userVm.currentUser, currentUser.id != user.user.id, post.status != .HAS_ENDED {
                                    
                                    Menu{
                                        if post.currentUserRole == .HOST && user._type == .NORMAL{
                                            Button("Make a Co-Host") {
                                                Task{
                                                    if try await APIClient.shared.addCoHostRoleToEvent(postId: post.id, userId: user.user.id) {
                                                        
                                                        if let index = eventVM.participantsList.firstIndex(where: { $0.user.id == user.user.id }) {
                                                            eventVM.participantsList[index]._type = .CO_HOST
                                                        }
                                                    }
                                                }
                                            }
                                        } else if post.currentUserRole == .HOST {
                                            Button("Remove as a Co-Host") {
                                                Task{
                                                    if try await APIClient.shared.removeCoHostRoleToEvent(postId: post.id, userId: user.user.id) {
                                                        
                                                        if let index = eventVM.participantsList.firstIndex(where: { $0.user.id == user.user.id }) {
                                                            eventVM.participantsList[index]._type = .NORMAL
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if post.currentUserStatus == .PARTICIPATING {
                                            Button{
                                                showReportSheet = true
                                                selectedExtendedUser = user
                                            } label:{
                                                Text("Report")
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        
                                        if  post.payment <= 0 && (post.currentUserRole == .HOST || post.currentUserRole == .CO_HOST) {
                                            Button("Remove") {
                                                Task{
                                                    if try await APIClient.shared.removeParticipant(postId: post.id, userId: user.user.id) {
                                                        
                                                        if let index = eventVM.participantsList.firstIndex(where: { $0.user.id == user.user.id }) {
                                                            eventVM.participantsList.remove(at: index)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .rotationEffect(.degrees(90))
                                    }
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
                        if !eventVM.listLastPage {
                            isLoading = true
                            
                            Task{
                                try await eventVM.fetchUserList(id: post.id)
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
                        try await eventVM.fetchUserList(id: post.id)
                        Init = false
                        
                    }
                    if post.askToJoin {
                        eventVM.joinRequestParticipantsList = []
                        eventVM.joinRequestParticipantsPage = 0
                        try await eventVM.fetchJoinRequestUserList(id: post.id)
                        
                    } else {
                        eventVM.waitingList = []
                        eventVM.waitingListPage = 0
                        try await eventVM.fetchWaitingList(id: post.id)
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .sheet(isPresented: $showReportSheet, content: {
            if let extendedUser = selectedExtendedUser {
                ReportUserView(user: extendedUser.user, isActive: $showReportSheet)
            }
        })
        .background(.bar)
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .swipeBack()

    }
}

#Preview {
    UsersListView(post: MockPost)
        .environmentObject(UserViewModel())
}
