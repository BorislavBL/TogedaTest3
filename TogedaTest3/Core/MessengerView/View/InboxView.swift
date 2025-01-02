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
    @StateObject var chatVM = ChatViewModel()
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
            
            if chatManager.allChatRooms.count > 0 {
                List {
                    ForEach(chatManager.allChatRooms, id: \.id){ chatroom in
                        InboxRowView(chatroom: chatroom)
                            .listRowSeparator(.hidden)
                            .overlay {
                                NavigationLink(value: SelectionPath.userChat(chatroom: chatroom)){
                                    Rectangle()
                                        .foregroundStyle(.red)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .opacity(0)
                            }
                            .swipeActions(allowsFullSwipe: false) {
                                if chatroom.isMuted {
                                    Button {
                                        Task{
                                            if let request = try await APIClient.shared.unmuteChat(chatId: chatroom.id) {
                                                if request {
                                                    print("is muted")
                                                    DispatchQueue.main.async{
                                                        if let index = chatManager.allChatRooms.firstIndex(where: {$0.id == chatroom.id}) {
                                                            print("1111")
                                                            chatManager.allChatRooms[index].isMuted = false
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        Label("Unmute", systemImage: "bell.fill")
                                    }
                                    .tint(.gray)

                                } else {
                                    Button {
                                        Task{
                                            if let request = try await APIClient.shared.muteChat(chatId: chatroom.id) {
                                                if request {
                                                    DispatchQueue.main.async{
                                                        print("is muted")
                                                        if let index = chatManager.allChatRooms.firstIndex(where: {$0.id == chatroom.id}) {
                                                            print("1111")
                                                            chatManager.allChatRooms[index].isMuted = true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        Label("Mute", systemImage: "bell.slash.fill")
                                    }
                                    .tint(.indigo)
                                }
                                
                                if chatroom._type == .GROUP {
                                    Button(role: .destructive) {
                                        Task{
                                            if let response = try await APIClient.shared.leaveGroupChatRoom(chatId: chatroom.id) {
                                                if response {
                                                    chatManager.allChatRooms.removeAll(where: {$0.id == chatroom.id})
                                                }
                                            }
                                        }
                                    } label: {
                                        Label("Leave", systemImage: "rectangle.portrait.and.arrow.right")
                                    }
                                }
                            }
                        
                    }
                    .padding(.top)
                    .listRowBackground(Color.clear)
                    
                    if isLoading {
                        ProgressView()
                            .listRowSeparator(.hidden)// Show spinner while loading
                            .listRowBackground(Color.clear)

                    }
                    
                    Rectangle()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
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
                .listStyle(PlainListStyle())
                .scrollIndicators(.hidden)
                .background(.bar)
                .refreshable {
                    Task{
                        chatManager.allChatRooms = []
                        chatManager.lastChatPage = true
                        chatManager.chatPage = 0
                        try await chatManager.getAllChats()
                        isLoading = false
                        
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
            } else {
                VStack(spacing: 15){
                    Text("🫵")
                        .font(.custom("image", fixedSize: 120))
                    
                    Text("Looks a little quiet here! Start by joining events or clubs around you to make new friends, and jump into chats with people who share your vibe!")
                        .font(.body)
                        .foregroundStyle(.gray)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                }
                .padding(.all)
                .frame(maxHeight: .infinity, alignment: .center)
                .background(.bar)
            }
        }
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
                        .background(.gray)
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            case .FRIENDS:
                if chatroom.previewMembers.count > 0 {
                    KFImage(URL(string: chatroom.previewMembers[0].profilePhotos[0]))
                        .resizable()
                        .scaledToFill()
                        .background(.gray)
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                }
            case .GROUP:
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
                            HStack(spacing: 5){
                                Text("\(chatroom.previewMembers[0].firstName) \(chatroom.previewMembers[0].lastName)")
                                    .lineLimit(1)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                if chatroom.previewMembers[0].userRole == .AMBASSADOR {
                                    AmbassadorSealMini()
                                } else if chatroom.previewMembers[0].userRole == .PARTNER {
                                    PartnerSealMini()
                                }
                            }
                        }
                    case .GROUP:
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
