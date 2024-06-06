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
    @State var showUserOptions = false
    @State var selectedExtendedUser: Components.Schemas.ExtendedMiniUser?
    @State var Init: Bool = true
    
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                if post.status != .HAS_ENDED && post.askToJoin && eventVM.joinRequestParticipantsList.count > 0 && (post.currentUserRole == .CO_HOST || post.currentUserRole == .HOST){
                    NavigationLink(value: SelectionPath.eventUserJoinRequests(post: post)){
                        UserRequestTab(users: eventVM.joinRequestParticipantsList)
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
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .sheet(isPresented: $showUserOptions, content: {
            List {
                if let extendedUser = selectedExtendedUser {
                    if post.currentUserRole == .HOST && extendedUser._type == .NORMAL{
                        Button("Make a Co-Host") {
                            Task{
                                if try await APIClient.shared.addCoHostRoleToEvent(postId: post.id, userId: extendedUser.user.id) {
                                    
                                    if let index = eventVM.participantsList.firstIndex(where: { $0.user.id == extendedUser.user.id }) {
                                        eventVM.participantsList[index]._type = .CO_HOST
                                    }
                                    
                                    showUserOptions = false
                                }
                            }
                        }
                    } else if extendedUser._type == .HOST {
                        Button("Remove as a Co-Host") {
                            Task{
                                if try await APIClient.shared.removeCoHostRoleToEvent(postId: post.id, userId: extendedUser.user.id) {
                                    
                                    if let index = eventVM.participantsList.firstIndex(where: { $0.user.id == extendedUser.user.id }) {
                                        eventVM.participantsList[index]._type = .NORMAL
                                    }
                                    
                                    showUserOptions = false
                                }
                            }
                        }
                    }
                    
                    if post.currentUserStatus == .PARTICIPATING {
                        Button("Report") {

                        }
                    }
                    
                    if  post.currentUserRole == .HOST || post.currentUserRole == .CO_HOST {
                        Button("Remove") {
                            Task{
                                if try await APIClient.shared.removeParticipant(postId: post.id, userId: extendedUser.user.id) {
                                    
                                    if let index = eventVM.participantsList.firstIndex(where: { $0.user.id == extendedUser.user.id }) {
                                        eventVM.participantsList.remove(at: index)
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
            .presentationDetents([.fraction(0.20)])
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
    UsersListView(post: MockPost)
}
