//
//  GroupSettingsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 26.12.24.
//

import SwiftUI
import Kingfisher

struct GroupSettingsView: View {
    @State var chatroom: Components.Schemas.ChatRoomDto
    var size: ImageSize = .xLarge
    
    @EnvironmentObject var chatManager: WebSocketManager
    @EnvironmentObject var navManager: NavigationManager
    @EnvironmentObject var userVM: UserViewModel
    
    @State var showFriendsSheet = false
    @State private var leaveChatSheet: Bool = false
    @State private var canLeave = false
    @State private var dispalyOwnerError = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12){
                if let image = chatroom.image {
                    KFImage(URL(string: image))
                        .resizable()
                        .scaledToFill()
                        .background(.gray)
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    
                } else if chatroom.previewMembers.count > 1 {
                    ZStack(alignment:.top){
                        
                        KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .background(.gray)
                            .frame(width: 2 * size.dimension/3, height: 2 * size.dimension/3)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color("base"), lineWidth: 2)
                            )
                            .offset(y: -size.dimension/6)
                        
                        KFImage(URL(string: chatroom.previewMembers[1].profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .background(.gray)
                            .frame(width: 2 * size.dimension/3, height: 2 * size.dimension/3)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color("base"), lineWidth: 2)
                            )
                            .offset(x: size.dimension/6, y: size.dimension/6)
                        
                    }
                    .padding([.trailing, .bottom], size.dimension/3)
                }
                
                if let title = chatroom.title {
                    Text("\(title)")
                        .lineLimit(1)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                else if chatroom.previewMembers.count > 1 {
                    Text("\(chatroom.previewMembers[0].firstName), \(chatroom.previewMembers[1].firstName)")
                        .lineLimit(1)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack(spacing: 40){
                    Button {
                        showFriendsSheet = true
                    } label:{
                        VStack(spacing: 12){
                            Image(systemName: "person.badge.plus")
                                .font(.title2)
                            Text("Add")
                                .font(.footnote)
                        }
                    }
                    
                    if chatroom.isMuted {
                        Button {
                            Task{
                                if let request = try await APIClient.shared.unmuteChat(chatId: chatroom.id) {
                                    if request {
                                        DispatchQueue.main.async {
                                            if let index = chatManager.allChatRooms.firstIndex(where: {$0.id == chatroom.id}) {
                                                chatManager.allChatRooms[index].isMuted = false
                                                chatroom.isMuted = false
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            VStack(spacing: 12){
                                Image(systemName: "bell")
                                    .font(.title2)
                                Text("Mute")
                                    .font(.footnote)
                            }
                        }

                    } else {
                        Button {
                            Task{
                                if let request = try await APIClient.shared.muteChat(chatId: chatroom.id) {
                                    if request {
                                        DispatchQueue.main.async {
                                            if let index = chatManager.allChatRooms.firstIndex(where: {$0.id == chatroom.id}) {
                                                chatManager.allChatRooms[index].isMuted = true
                                                chatroom.isMuted = true
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            VStack(spacing: 12){
                                Image(systemName: "bell.slash")
                                    .font(.title2)
                                Text("Unmute")
                                    .font(.footnote)
                            }
                        }
                        .tint(.indigo)
                    }
                    
                    if let cuser = userVM.currentUser, let owner = chatroom.owner, cuser.id == owner.id {
                        if canLeave {
                            Button {
                                leaveChatSheet = true
                            } label:{
                                VStack(spacing: 12){
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.title2)
                                    Text("Leave")
                                        .font(.footnote)
                                }
                            }
                        } else {
                            VStack(spacing: 12){
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                Text("Leave")
                                    .font(.footnote)
                            }.onTapGesture {
                                dispalyOwnerError.toggle()
                            }
                        }
                    } else {
                        Button {
                            leaveChatSheet = true
                        } label:{
                            VStack(spacing: 12){
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                Text("Leave")
                                    .font(.footnote)
                            }
                        }
                    }
                }
                .padding()
                
                if dispalyOwnerError{
                    WarningTextComponent(text: "As the group owner, you can only leave if the group has no remaining members.")
                        .padding(.bottom)
                }
                
                NavigationLink(value: SelectionPath.editGroupChat(chatroom: chatroom)) {
                    HStack(spacing: 15){
                        Image(systemName: "square.and.pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text("Edit Group")
                        
                        
                        Spacer()
                        
                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.gray)
                        
                    }
                }
                
                NavigationLink(value: SelectionPath.chatParticipants(chatroom: chatroom)) {
                    HStack(spacing: 15){
                        Image(systemName: "person.2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        VStack(alignment: .leading){
                            Text("Participants")
                            Text("\(chatroom.previewMembers[0].firstName), \(chatroom.previewMembers[1].firstName)")
                                .lineLimit(1)
                                .font(.footnote)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.forward")
                            .foregroundStyle(.gray)
                        
                    }
                }
                
            }
            .padding()
        }
        .onAppear(){
            if let cuser = userVM.currentUser, let owner = chatroom.owner, cuser.id == owner.id {
                Task{
                    do{
                        if let response = try await APIClient.shared.getChatParticipants(chatId: chatroom.id, page: 0, size: 15) {
                            if response.data.count == 1 {
                                canLeave = true
                            }
                        }
                    } catch {
                        print("User list error:", error.localizedDescription)
                    }
                }
            }
        }
        .sheet(isPresented: $showFriendsSheet) {
            InviteFriendsToGroupSheet(chatId: chatroom.id)
                .presentationDetents([.fraction(0.8), .fraction(1)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $leaveChatSheet) {
            VStack(spacing: 30){
                Text("Leave Group Chat")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Button{
                    leaveChatSheet = false
                    Task {
                        do {
                            if let request = try await APIClient.shared.leaveGroupChatRoom(chatId: chatroom.id) {
                                chatManager.allChatRooms.removeAll(where: {$0.id == chatroom.id})
                                
                                navManager.selectionPath = []
                            }
                        } catch {
                            print("error leave chat:", error)
                        }
                    }
                } label:{
                    Text("Leave")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(.red)
                        .cornerRadius(10)
                }
            }
            .padding()
            .presentationDetents([.height(200)])
        }
    }
}

#Preview {
    GroupSettingsView(chatroom: mockChatRoom)
        .environmentObject(NavigationManager())
        .environmentObject(WebSocketManager())
        .environmentObject(UserViewModel())
}
