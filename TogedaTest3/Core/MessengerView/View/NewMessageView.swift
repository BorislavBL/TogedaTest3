//
//  NewMessageView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.11.23.
//

import SwiftUI
import Kingfisher

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @State var searchText: String = ""
    @ObservedObject var chatVM: ChatViewModel
    @StateObject var newChatVM = NewChatViewModel()
    
    let size: ImageSize = .small
    @State var showGroupChat = false
    
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var chatManager: WebSocketManager
    
    @State var isLoading = false
    
    @State var Init: Bool = true
    @State var friendsList: [Components.Schemas.GetFriendsDto] = []
    @State var lastPage = true
    @State var page: Int32 = 0
    @State var pageSize: Int32 = 15
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("CONTACTS")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                LazyVStack {
                    ForEach(friendsList, id:\.user.id) { userData in
                        VStack {
                            Button{
                                Task{
                                    if let chatRoom = try await APIClient.shared.getChat(chatId: userData.chatRoomId) {
                                        dismiss()
                                        chatVM.selectedUser = userData.user
                                        navManager.selectionPath.append(SelectionPath.userChat(chatroom: chatRoom))
                                        print("Chat id:", userData.chatRoomId)
                                    }
                                }
                                
//                                else {
//                                    Task{
//                                        if let currentUser = userVm.currentUser, let response = try await APIClient.shared.createChatForFriends(senderId: currentUser.id, recipientId:userData.user.id ) {
//                                            
//                                            dismiss()
//                                            
//                                            chatVM.selectedUser = userData.user
//                                            navManager.selectionPath.append(.userChat(toUser: userData.user, chatId: response.id))
//                                            
//                                            print("Chat id:", response.id)
//                                        }
//                                    }
//                                }
                                
                            } label:{
                                HStack {
                                    KFImage(URL(string: userData.user.profilePhotos[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.dimension, height: size.dimension)
                                        .clipShape(Circle())
                                    
                                    Text("\(userData.user.firstName) \(userData.user.lastName)")
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
                            if !lastPage, let currentUser = userVm.currentUser {
                                isLoading = true
                                
                                Task{
                                    if let response = try await APIClient.shared.getFriendList(userId: currentUser.id, page: page, size: pageSize){
                                        
                                        let newResponse = response.data
                                        let existingResponseIDs = Set(self.friendsList.suffix(30).map { $0.user.id })
                                        let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.user.id) }
                                        
                                        friendsList += uniqueNewResponse
                                        page += 1
                                        lastPage = response.lastPage
                                    }
                                    isLoading = false
                                    
                                }
                            }
                        }
                }
            }
            .onAppear(){
                Task{
                    do{
                        if let currentUser = userVm.currentUser, Init {
                            if let response = try await APIClient.shared.getFriendList(userId: currentUser.id, page: page, size: pageSize){
                                friendsList = response.data
                                page += 1
                                lastPage = response.lastPage
                            }
                            Init = false
                        }
                    } catch {
                        print("User list error:", error.localizedDescription)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showGroupChat){
                NewGroupChatView(newChatVM: newChatVM)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Make Group") {
                        showGroupChat = true
                    }
                }
            }
        }
    }
}

#Preview {
    NewMessageView(chatVM: ChatViewModel())
        .environmentObject(NavigationManager())
        .environmentObject(UserViewModel())
        .environmentObject(WebSocketManager())
}
