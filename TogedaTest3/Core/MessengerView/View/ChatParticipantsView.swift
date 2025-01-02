//
//  ChatParticipantsView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 26.08.24.
//

import SwiftUI
import Kingfisher

struct ChatParticipantsView: View {
    @Environment(\.dismiss) private var dismiss
    let size: ImageSize = .medium
    
    @State var isLoading = false
    @State var showReportSheet = false
    @State var Init: Bool = true
    var chatRoom: Components.Schemas.ChatRoomDto
    
    @State var lastPage: Bool = true
    @State var page: Int32 = 0
    @State var pageSize: Int32 = 15
    @State var participants: [Components.Schemas.MiniUser] = []
    
    @State private var showFriendsSheet: Bool = false

    
    @EnvironmentObject var chatManager: WebSocketManager
    var body: some View {
        ScrollView{
            LazyVStack(alignment:.leading){
                ForEach(participants, id:\.id) { user in
                    HStack{
                        NavigationLink(value: SelectionPath.profile(user)){
                            HStack{
                                KFImage(URL(string: user.profilePhotos[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())
                                VStack(alignment: .leading){
                                    Text("\(user.firstName) \(user.lastName)")
                                        .fontWeight(.semibold)
                                    if let owner = chatRoom.owner, owner.id == user.id {
                                        Text("Owner")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.gray)
                                            .font(.footnote)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if let owner = chatRoom.owner, owner.id == user.id {
                            Menu{
                                Button("Kick \(user.firstName)"){
                                    Task{
                                        if let request = try await APIClient.shared.kickGroupParticipant(userId: user.id, chatId: chatRoom.id){
                                            if request {
                                                participants.removeAll(where: {$0.id == user.id})
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
                    .padding(.vertical, 5)
                }
                
                if isLoading{
                    ProgressView()
                }
                
                Rectangle()
                    .frame(width: 0, height: 0)
                    .onAppear {
                        if !lastPage {
                            isLoading = true
                            
                            Task{
                                if let response = try await APIClient.shared.getChatParticipants(chatId: chatRoom.id, page: page, size: pageSize) {
                                    self.participants += response.data
                                    self.lastPage = response.lastPage
                                    self.page += 1
                                }
                                isLoading = false
                                
                            }
                        }
                    }
            }
            .padding(.horizontal)
            .padding(.top)
            
        }
        .refreshable {
            self.participants = []
            self.lastPage = true
            self.page = 0
            
            Task{
                if let response = try await APIClient.shared.getChatParticipants(chatId: chatRoom.id, page: page, size: pageSize) {
                    self.participants += response.data
                    self.lastPage = response.lastPage
                    self.page += 1
                }
            }
        }
        .onAppear(){
            Task{
                do{
                    if Init {
                        if let response = try await APIClient.shared.getChatParticipants(chatId: chatRoom.id, page: page, size: pageSize) {
                            self.participants += response.data
                            self.lastPage = response.lastPage
                            self.page += 1
                        }
                        
                        Init = false
                    }
                } catch {
                    print("User list error:", error.localizedDescription)
                }
            }
        }
        .background(.bar)
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showFriendsSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .swipeBack()
        .sheet(isPresented: $showFriendsSheet) {
            InviteFriendsToGroupSheet(chatId: chatRoom.id)
                .presentationDetents([.fraction(0.8), .fraction(1)])
                .presentationDragIndicator(.visible)
        }
    }
    
}

#Preview {
    ChatParticipantsView(chatRoom: mockChatRoom)
        .environmentObject(WebSocketManager())
}
