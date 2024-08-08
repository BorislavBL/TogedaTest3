//
//  InboxView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 10.11.23.
//

import SwiftUI
import Kingfisher

struct InboxView: View {
    @EnvironmentObject var chatManager: WebSocketManager
    @ObservedObject var chatVM: ChatViewModel
    @State private var showNewMessageView = false
    @State var searchText: String = ""
    @State var messages: [Message] = Message.MOCK_MESSAGES
    @State var isSearching: Bool = false
    @State var searchUserResults: [Components.Schemas.MiniUser] = [MockMiniUser]
    
    @State var navHeight: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0){
            VStack{
                ZStack(alignment: .trailing){
                    Text("Chats")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                    Image(systemName: "square.and.pencil.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(Color("blackAndWhite"), Color(.systemGray5))
                        .onTapGesture {
                            showNewMessageView.toggle()
                            chatVM.selectedUser = nil
                        }
                }
                .padding(.horizontal)
                
                CustomSearchBar(searchText: .constant(""), showCancelButton: $isSearching)
                    .padding(.horizontal)
                
                Divider()
            }
            .background(.bar)
            
            List {
                ForEach(chatManager.allChatRooms, id: \.id){ chatroom in
                        ZStack{
                            NavigationLink(value: SelectionPath.userChat(chatroom: chatroom)){
                                EmptyView()
                            }
                            .opacity(0)
                            InboxRowView(chatroom: chatroom)
                        }
                    
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.top)
                .padding(.horizontal)
            }
            .overlay{
                if isSearching {
                    ChatSearchView()
                }
            }
        }
        .listStyle(PlainListStyle())
        .scrollIndicators(.hidden)
        .fullScreenCover(isPresented: $showNewMessageView, content: {
            NewMessageView(chatVM: chatVM)
        })
        
    }
}

struct InboxRowView: View {
    var chatroom: Components.Schemas.ChatRoomDto
    var size: ImageSize = .medium
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            
            switch chatroom._type{
            case .CLUB:
                if let club = chatroom.club {
                    KFImage(URL(string: club.images[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            case .FRIENDS:
                if chatroom.previewMembers.count > 0 {
                    KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            case .GROUP:
                if chatroom.previewMembers.count > 1 {
                    KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            case .POST:
                if let post = chatroom.post {
                    KFImage(URL(string: post.images[0]))
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
                
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack{
                    switch chatroom._type{
                    case .CLUB:
                        if let club = chatroom.club {
                            Text("\(club.title)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                        }
                    case .FRIENDS:
                        if chatroom.previewMembers.count > 0 {
                            Text("\(chatroom.previewMembers[0].firstName) \(chatroom.previewMembers[0].lastName)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    case .GROUP:
                        if chatroom.previewMembers.count > 1 {
                            Text("\(chatroom.previewMembers[0].firstName) \(chatroom.previewMembers[1].firstName)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    case .POST:
                        if let post = chatroom.post {
                            Text("\(post.title)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                        }
                        
                    }

                    
                    Spacer(minLength: 10)
                    
                    Text("\(chatroom.latestMessageTimestamp.formatted())")
                        .font(.footnote)
                        .foregroundColor(!chatroom.read ? Color(.systemBlue) : .gray)
                        .lineLimit(2)
                }
                
                HStack(alignment: .top){
                    Text(chatroom.latestMessage?.content ?? "")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    if !chatroom.read{
                        Spacer(minLength: 10)
                        
                        Circle()
                            .fill(Color(.systemBlue))
                            .frame(width: 12, height: 12, alignment: .leading)
                    }
                    
                }
            }
        }
    }
}

#Preview {
    InboxView(chatVM: ChatViewModel())
        .environmentObject(PostsViewModel())
        .environmentObject(WebSocketManager())
}
