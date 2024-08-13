//
//  NewGroupChatView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 28.11.23.
//

import SwiftUI
import WrappingHStack
import Kingfisher

struct NewGroupChatView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var newChatVM: NewChatViewModel
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var chatManager: WebSocketManager
    @State var searchText: String = ""
    let size: ImageSize = .small
    @State var searchUserResults: [Components.Schemas.GetFriendsDto] = []
    @State var selectedUsers: [Components.Schemas.GetFriendsDto] = []
    @State private var showNewGroupChatCreateView = false
    
    @State var friendsList: [Components.Schemas.GetFriendsDto] = []
    @State var lastPage: Bool = true
    @State var page: Int32 = 0
    @State var listSize: Int32 = 15
    @State var isLoading = false
    
    var body: some View {
        ScrollView {
            //                TextField("To: ", text: $searchText)
            //                    .frame(height: 44)
            //                    .padding(.leading)
            //                //                    .background(Color(.systemGroupedBackground))
            //                    .background(Color(.tertiarySystemFill))
            
            if selectedUsers.count > 0{
                ScrollView{
                    WrappingHStack(alignment: .topLeading){
                        ForEach(selectedUsers, id: \.user.id) { user in
                            ParticipantsChatTags(user: user){
                                selectedUsers.removeAll(where: { $0.user.id == user.user.id })
                            }
                        }
                    }
                }
                .padding()
                .frame(maxHeight: 100)
            }
            
            Text("CONTACTS")
                .foregroundColor(.gray)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            
            LazyVStack {
                ForEach(friendsList, id: \.user.id) { user in
                    VStack {
                        Button{
                            if selectedUsers.contains(where:{ $0.user.id == user.user.id}) {
                                selectedUsers.removeAll(where: { $0.user.id == user.user.id })
                            } else {
                                selectedUsers.append(user)
                            }
                        } label:{
                            HStack {
                                if selectedUsers.contains(where:{ $0.user.id == user.user.id}){
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .imageScale(.large)
                                        .foregroundStyle(.gray)
                                }
                                
                                KFImage(URL(string: user.user.profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                                
                                Text("\(user.user.firstName) \(user.user.lastName)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                        }
                        
                        Divider()
                            .padding(.leading, 40)
                    }
                    .padding(.leading)
                }
                
                if isLoading{
                    ProgressView()
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !lastPage{
                            isLoading = true
                            Task{
                                try await fetchList()
                                isLoading = false
                                
                            }
                        }
                        
                    }
            }
        }
        .onAppear(){
            Task{
                try await fetchList()
            }
        }
        .navigationTitle("New Group")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button{
                    dismiss()
                } label:{
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if selectedUsers.count > 0 {
                    Button{
                        //                            showNewGroupChatCreateView = true
                        create()
                    } label:{Text("Create")}
                } else {
                    Text("Create")
                        .foregroundStyle(.gray)
                }
            }
        }
        //            .navigationDestination(isPresented: $showNewGroupChatCreateView) {
        //                NewGroupChatCreateView(newChatVM: newChatVM)
        //            }
        
    }
    
    func create() {
        let ids = friendsList.map({ friend in
            return friend.user.id
        })
        Task {
            if let response = try await APIClient.shared.createGroupChat(friendIds: .init(friendIds: ids)) {
                if let chatRoom = try await APIClient.shared.getChat(chatId: response) {
                    DispatchQueue.main.async {
                        dismiss()
                        dismiss()
                        
                        navManager.selectionPath.append(SelectionPath.userChat(chatroom: chatRoom))
                    }
                }
            }
        }
    }
    
    func fetchList() async throws {
        if let currentUser = userVm.currentUser {
            if let response = try await APIClient.shared.getFriendList(userId: currentUser.id, page: page, size: listSize) {
                
                let newResponse = response.data
                let existingResponseIDs = Set(self.friendsList.suffix(30).map { $0.user.id })
                let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.user.id) }
                
                friendsList = uniqueNewResponse
                page += 1
                lastPage = response.lastPage
            }
        }
    }
    
    
}

struct ParticipantsChatTags: View {
    var user: Components.Schemas.GetFriendsDto
    let size: ImageSize = .xxSmall
    @State var clicked = false
    var action: () -> Void
    var body: some View {
        if clicked {
            Button{action()} label:{
                HStack{
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                    
                    
                    Text("\(user.user.firstName) \(user.user.lastName)")
                        .font(.subheadline)
                    
                }
                .frame(height: size.dimension)
                .padding(.horizontal, 8)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        } else {
            Button{clicked = true} label:{
                HStack{
                    KFImage(URL(string: user.user.profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                    
                    Text("\(user.user.firstName) \(user.user.lastName)")
                        .font(.subheadline)
                        .padding(.trailing, 8)
                }
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }
        }
        
    }
}

#Preview {
    NewGroupChatView(newChatVM: NewChatViewModel())
        .environmentObject(NavigationManager())
        .environmentObject(UserViewModel())
        .environmentObject(WebSocketManager())
}

