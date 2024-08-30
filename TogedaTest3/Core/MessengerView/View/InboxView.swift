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

    
    @State var navHeight: CGFloat = .zero
    @State var isLoading = false
    
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
                
                CustomSearchBar(searchText: $chatVM.searchText, showCancelButton: $chatVM.isSearching)
                    .padding(.horizontal)
                
                Divider()
            }
            .background(.bar)
            
            ScrollView {
                LazyVStack {
                    ForEach(chatManager.allChatRooms, id: \.id){ chatroom in
                        NavigationLink(value: SelectionPath.userChat(chatroom: chatroom)){
                            InboxRowView(chatroom: chatroom)
                        }
                        
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    
                    if isLoading {
                        ProgressView() // Show spinner while loading
                    }
                    
                    Rectangle()
                        .frame(width: 0, height: 0)
                        .onAppear {
                            if !chatManager.lastChatPage{
                                isLoading = true
                                Task{
                                    try await chatManager.getAllChats()
                                    isLoading = false
                                    
                                }
                            }
                        }
                }
            }
            .overlay{
                if chatVM.isSearching {
                    ChatSearchView(chatVM: chatVM)
                        .onAppear(){
                            chatVM.startSearch()
                        }
                        .onDisappear(){
                            chatVM.stopSearch()
                        }
                }
            }
        }
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
                    ZStack(alignment:.top){
                        
                        KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
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
                                .lineLimit(1)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    case .FRIENDS:
                        if chatroom.previewMembers.count > 0 {
                            Text("\(chatroom.previewMembers[0].firstName) \(chatroom.previewMembers[0].lastName)")
                                .lineLimit(1)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    case .GROUP:
                        if chatroom.previewMembers.count > 1 {
                            Text("\(chatroom.previewMembers[0].firstName), \(chatroom.previewMembers[1].firstName)")
                                .lineLimit(1)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    case .POST:
                        if let post = chatroom.post {
                            Text("\(post.title)")
                                .lineLimit(1)
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
                    if let message = chatroom.latestMessage {
                        switch message.contentType {
                        case .CLUB:
                            Text("Sent Club")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        case .IMAGE:
                            Text("Sent Image")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        case .POST:
                            Text("Sent Post")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        case .NORMAL:
                            Text(message.content)
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        
                    } else {
                        Text("")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
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
