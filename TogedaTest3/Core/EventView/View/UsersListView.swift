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
        VStack{
            HStack(spacing: 16){
                CustomSearchBar(searchText: $eventVM.searchText, showCancelButton: $eventVM.showCancelButton)
            }
            .padding()
            
            List {
                //            LazyVStack(alignment:.leading){
                if post.status != .HAS_ENDED && post.askToJoin && eventVM.joinRequestParticipantsList.count > 0 && (post.currentUserRole == .CO_HOST || post.currentUserRole == .HOST){
                    
                    UserRequestTab(users: joinRequestParticipantsAsMiniUsers)
                        .overlay {
                            NavigationLink(value: SelectionPath.eventUserJoinRequests(post: post)){
                                Rectangle()
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .opacity(0)
                        }
                    
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                
                if post.status != .HAS_ENDED && !post.askToJoin && eventVM.waitingList.count > 0 && (post.currentUserRole == .CO_HOST || post.currentUserRole == .HOST){
                    
                    UserWaitingTab(users: eventVM.waitingList)
                        .overlay {
                            NavigationLink(value: SelectionPath.eventWaitingList(post)){
                                Rectangle()
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .opacity(0)
                        }
                    
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                
                ForEach(eventVM.participantsList, id:\.user.id) { user in
                    UserTab(user: user)
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 5)
                        .swipeActions(edge: .trailing) {
                            if (user._type != .HOST && user._type != .CO_HOST) &&
                                (post.currentUserRole == .HOST || post.currentUserRole == .CO_HOST) &&
                                user.locationStatus != .NOT_SHOWN{
                                Button {
                                    Task{
                                        try await eventVM.changeUserStatus(postId: post.id, userId: user.user.id, status: .NOT_SHOWN)
                                    }
                                } label: {
                                    Label("Not Shown", systemImage: "xmark.circle")
                                        .foregroundStyle(.white)
                                }
                                .tint(.red)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            if (user._type != .HOST && user._type != .CO_HOST) &&
                                (post.currentUserRole == .HOST || post.currentUserRole == .CO_HOST) &&
                                user.locationStatus != .ARRIVED {
                                
                                Button {
                                    Task{
                                        try await eventVM.changeUserStatus(postId: post.id, userId: user.user.id, status: .ARRIVED)
                                    }
                                } label: {
                                    Label("Arrived", systemImage: "checkmark.circle")
                                        .foregroundStyle(.white)
                                }
                                .tint(.green)
                            }
                        }
                    
                }
                .listRowBackground(Color.clear)
                
                ListLoadingButton(isLoading: $isLoading, isLastPage: eventVM.listLastPage) {
                    Task{
                        defer{isLoading = false}
                        try await eventVM.fetchUserList(id: post.id)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                //            }
                //            .padding(.horizontal)
                
            }
            .listStyle(PlainListStyle())
            .scrollIndicators(.hidden)
            .overlay {
                if !eventVM.searchedParticipantsList.isEmpty {
                    List {
                        ForEach(eventVM.searchedParticipantsList, id:\.user.id) { user in
                            UserTab(user: user)
                                .listRowSeparator(.hidden)
                                .padding(.vertical, 5)
                                .swipeActions(edge: .trailing) {
                                    if (user._type != .HOST && user._type != .CO_HOST) &&
                                        (post.currentUserRole == .HOST || post.currentUserRole == .CO_HOST) &&
                                        user.locationStatus != .NOT_SHOWN{
                                        Button {
                                            Task{
                                                try await eventVM.changeUserStatus(postId: post.id, userId: user.user.id, status: .NOT_SHOWN)
                                            }
                                        } label: {
                                            Label("Not Shown", systemImage: "xmark.circle")
                                                .foregroundStyle(.white)
                                        }
                                        .tint(.red)
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    if (user._type != .HOST && user._type != .CO_HOST) &&
                                        (post.currentUserRole == .HOST || post.currentUserRole == .CO_HOST) &&
                                        user.locationStatus != .ARRIVED {
                                        
                                        Button {
                                            Task{
                                                try await eventVM.changeUserStatus(postId: post.id, userId: user.user.id, status: .ARRIVED)
                                            }
                                        } label: {
                                            Label("Arrived", systemImage: "checkmark.circle")
                                                .foregroundStyle(.white)
                                        }
                                        .tint(.green)
                                    }
                                }
                            
                        }
                        .listRowBackground(Color.clear)
                        
                        ListLoadingButton(isLoading: $isLoading, isLastPage: eventVM.listLastPage) {
                            Task{
                                defer{eventVM.isSearchLoading = false}
                                try await eventVM.searchUsers(postId: post.id)
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    .background(.bar)
                    .scrollIndicators(.hidden)
                }
            }
        }
        .background(.bar)
        .onAppear(){
            eventVM.startSearch(postId: post.id)
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
        .onDisappear(){
            eventVM.stopSearch()
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
        //        .swipeBack()
        
    }
    
    @ViewBuilder
    func UserTab(user: Components.Schemas.ExtendedMiniUser) -> some View {
        HStack{
            HStack{
                KFImage(URL(string: user.user.profilePhotos[0]))
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(Circle())
                
                VStack(alignment: .leading){
                    HStack(spacing: 5) {
                        Text("\(user.user.firstName) \(user.user.lastName)")
                            .fontWeight(.semibold)
                        
                        if user.user.userRole == .AMBASSADOR {
                            AmbassadorSealMini()
                        } else if user.user.userRole == .PARTNER {
                            PartnerSealMini()
                        }
                    }
                    if user._type == .CO_HOST || user._type == .HOST {
                        Text(user._type.rawValue.capitalized)
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                            .font(.footnote)
                    } else {
                        if user.locationStatus == .ARRIVED {
                            Text("Arrived")
                                .foregroundColor(.green)
                                .fontWeight(.semibold)
                                .font(.footnote)
                        } else if user.locationStatus == .NOT_SHOWN{
                            Text("Not Shown")
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                                .font(.footnote)
                        }
                    }
                    
                    
                    
                }
                
                
            }
            .overlay {
                NavigationLink(value: SelectionPath.profile(user.user)){
                    Rectangle()
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .opacity(0)
            }
            
            
            Spacer()
            
            if let c_user = userVm.currentUser, c_user.id != user.user.id {
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
                                
                                if (post.currentUserRole == .HOST || post.currentUserRole == .CO_HOST) && user._type == .NORMAL {
                                    if user.locationStatus != .ARRIVED {
                                        Button("Arrived") {
                                            Task{
                                                try await eventVM.changeUserStatus(postId: post.id, userId: user.user.id, status: .ARRIVED)
                                            }
                                        }
                                    }
                                    if user.locationStatus != .NOT_SHOWN {
                                        Button("Not Shown") {
                                            Task{
                                                try await eventVM.changeUserStatus(postId: post.id, userId: user.user.id, status: .NOT_SHOWN)
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
                                    .padding()
                            }
                        }
                    }
                }
            }
            
            
            
        }
    }
}

#Preview {
    UsersListView(post: MockPost)
        .environmentObject(UserViewModel())
}
