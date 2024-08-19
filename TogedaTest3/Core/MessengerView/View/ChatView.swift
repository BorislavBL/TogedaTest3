//
//  ChatView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.23.
//

import SwiftUI
import Kingfisher

struct ChatView: View {
    @State private var messageText = ""
    @State private var isInitialLoad = true
    @State private var Init = true
    @StateObject var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    var chatRoom: Components.Schemas.ChatRoomDto
    @State var isLoading: Bool = false
    @State var shouldStartLoading: Bool = true
    @State var shouldNotScrollToBottom: Bool = false
    @EnvironmentObject var chatManager: WebSocketManager
    @EnvironmentObject var userVm: UserViewModel
    @State var isChatActive: Bool = false
    @State var atBottom: Bool = false
    @State var activateArrow: Bool = false
    
    var body: some View {
        ZStack(alignment: .top){
            VStack{
                ScrollViewReader { proxy in
                    ScrollView{
                        LazyVStack{
                            if let currentUser = userVm.currentUser{
                                
                                if chatManager.messages.count == 0 && !Init{
                                    VStack{
                                        Text("Write a message to start the chat.")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .padding()
                                            .normalTagRectangleStyle()
                                            .padding()
                                    }
                                }
                                
                                if isLoading {
                                    ProgressView() // Show spinner while loading
                                }
                                
                                ForEach(Array(chatManager.messages.enumerated()), id: \.element.id) { index, message in
                                    VStack{
                                        if index == 0 {
                                            Text("\(formatDateAndTime(date: message.createdAt))")
                                                .font(.footnote)
                                                .foregroundStyle(.gray)
                                                .padding(8)
                                        }
                                        else if index > 0, let date = Calendar.current.dateComponents([.minute], from: chatManager.messages[index - 1].createdAt, to: message.createdAt).minute, date > 30 {
                                            Text("\(formatDateAndTime(date: message.createdAt))")
                                                .font(.footnote)
                                                .foregroundStyle(.gray)
                                                .padding(8)
                                            
                                        }
                                        
                                        ChatMessageCell(message: message,
                                                        nextMessage: nextMessage(forIndex: index), currentUserId: currentUser.id, chatRoom: chatRoom, prevMessage: index > 0 ? chatManager.messages[index - 1] : nil, vm: viewModel)
                                    }
                                    
                                }
                                
                                if chatManager.messages.last?.sender.id == currentUser.id {
                                    //                            if ((viewModel.messages.last?.read) != nil) {
                                    //                                Text("Read")
                                    //                                    .font(.footnote)
                                    //                                    .foregroundStyle(.gray)
                                    //                                    .frame(maxWidth:.infinity, alignment: .trailing)
                                    //                                    .padding(.horizontal)
                                    //                            } else {
                                    Text("Sending")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .frame(maxWidth:.infinity, alignment: .trailing)
                                        .padding(.horizontal)
                                    //                            }
                                }
                                //
                                Color.clear
                                    .frame(height: 10)
                                    .id("Bottom")
                                    .onAppear(){
                                        atBottom = true
                                        activateArrow = false
                                    }
                                    .onDisappear(){
                                        atBottom = false
                                    }
                            }
                        }
                        .padding(.top, 70)
                        .padding(.vertical)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .frame(width: 0, height: 0)
                                    .onChange(of: geo.frame(in: .global).minY) { oldMinY, newMinY in
                                        print("\(newMinY)")
                                        if newMinY >= 90 && !isLoading && !chatManager.lastMessagesPage && shouldStartLoading && !isInitialLoad {
                                            shouldNotScrollToBottom = true
                                            shouldStartLoading = false
                                            isLoading = true
                                            Task {
                                                defer {
                                                    Task{
                                                        isLoading = false
                                                        try await Task.sleep(nanoseconds: 2_000_000_000)
                                                        shouldStartLoading = true
                                                    }
                                                } // Ensure isLoading is set to false after the task completes
                                                do {
                                                    try await chatManager.getMessages(chatId: chatRoom.id)
                                                } catch {
                                                    print("Failed to get messages: \(error)")
                                                }
                                            }
                                            
                                            print("Triggered")
                                        }
                                    }
                            }
                        )
                        
                        
                    }
                    .defaultScrollAnchor(.bottom)
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: chatManager.messages) { oldValue, newValue in
                        if !shouldNotScrollToBottom && !isInitialLoad && atBottom {
                            withAnimation(.spring()) {
                                proxy.scrollTo("Bottom", anchor:.bottom)
                            }
                        }
                        
                        shouldNotScrollToBottom = false
                        
                        if !atBottom && newValue[0].content != oldValue[0].content {
                            activateArrow = true
                        }
                    }
                    .onChange(of: isChatActive) { oldValue, newValue in
                        if newValue && !atBottom {
                            withAnimation() {
                                proxy.scrollTo("Bottom", anchor:.bottom)
                            }
                        }
                    }
                    .overlay(alignment:.bottomTrailing){
                        if activateArrow {
                            Button{
                                withAnimation() {
                                    proxy.scrollTo("Bottom", anchor:.bottom)
                                }
                                
                                activateArrow = false
                            } label:{
                                Image(systemName: "arrow.down")
                                    .padding()
                                    .background(.bar)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                
                
                //            Spacer()
                
                MessageInputView(messageText: $messageText, isActive: $isChatActive, viewModel: viewModel) {
                    if let currentUser = userVm.currentUser {
                        if let uiImage = viewModel.messageImage {
                            Task {
                                if let imageURL = await viewModel.uploadImageAsync(uiImage: uiImage) {
                                    chatManager.sendMessage(senderId: currentUser.id, chatId: chatRoom.id, content: imageURL, type: .IMAGE)
                                    messageText = ""
                                    viewModel.messageImage = nil
                                }
                            }
                        }
                        else if !messageText.isEmpty {
                            chatManager.sendMessage(senderId: currentUser.id, chatId: chatRoom.id, content: messageText , type: .NORMAL)
                            messageText = ""
                        }
                    }
                }
                
            }
            
            navbar()
            
            if viewModel.isImageView, let image = viewModel.selectedImage{
                ImageViewer(isActive: $viewModel.isImageView, image: image)
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            onInit()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .swipeBack()
        .onAppear(){
            onInit()
        }
        .onDisappear(){
            chatManager.messagesToDefault()
        }
        
        
        
    }
    
    @ViewBuilder
    func navbar() -> some View {
        ZStack{
            HStack{
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
            }
            
            switch chatRoom._type {
            case .CLUB:
                if let club = chatRoom.club{
                    HStack{
                        KFImage(URL(string: club.images[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                        Text("\(club.title)")
                    }
                }
            case .FRIENDS:
                if chatRoom.previewMembers.count > 0 {
                    HStack{
                        KFImage(URL(string: chatRoom.previewMembers[0].profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                        if chatRoom.previewMembers.count > 0 {
                            Text("\(chatRoom.previewMembers[0].firstName) \(chatRoom.previewMembers[0].lastName)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            case .GROUP:
                if chatRoom.previewMembers.count > 1 {
                    HStack(alignment: .center){
                        if chatRoom.previewMembers.count > 1 {
                            ZStack(alignment:.top){
                               
                                KFImage(URL(string: chatRoom.previewMembers[0].profilePhotos[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 2 * 30/3, height: 2 * 30/3)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color("base"), lineWidth: 2)
                                        )
                                        .offset(y: -30/6)
                                        
                                KFImage(URL(string: chatRoom.previewMembers[1].profilePhotos[0]))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 2 * 30/3, height: 2 * 30/3)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color("base"), lineWidth: 2)
                                        )
                                        .offset(x: 30/6, y: 30/6)

                            }
                            .padding([.trailing, .bottom, .top], 30/3)
                        }
                        
                        if chatRoom.previewMembers.count > 1 {
                            Text("\(chatRoom.previewMembers[0].firstName), \(chatRoom.previewMembers[1].firstName) Group")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }
            case .POST:
                if let post = chatRoom.post{
                    HStack{
                        KFImage(URL(string: post.images[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                        if let post = chatRoom.post {
                            Text("\(post.title)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.bar)
    }
    
    func onInit() {
        Task{
            defer {
                Task{
                    Init = false
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    isInitialLoad = false
                }
            }
            await withCheckedContinuation { continuation in
                chatManager.messages = []
                chatManager.lastMessagesPage = true
                chatManager.messagesPage = 0
                continuation.resume()
            }
            
            try await chatManager.getMessages(chatId: chatRoom.id)
            
        }
    }
    
    var title: String {
        switch chatRoom._type {
        case .CLUB:
            if let club = chatRoom.club{
                return club.title
            }
        case .FRIENDS:
            if chatRoom.previewMembers.count > 0 {
                return "\(chatRoom.previewMembers[0].firstName) \(chatRoom.previewMembers[0].lastName)"
            }
        case .GROUP:
            if chatRoom.previewMembers.count > 1 {
                return "\(chatRoom.previewMembers[0].firstName) \(chatRoom.previewMembers[1].firstName)"
            }
        case .POST:
            if let post = chatRoom.post{
                return post.title
            }
        }
        
        return "Chat"
    }
    
    func nextMessage(forIndex index: Int) -> Components.Schemas.ReceivedChatMessageDto? {
        if index > 0 {
            return index != chatManager.messages.count - 1 ? chatManager.messages[index + 1] : nil
        }
        return nil
    }
}

#Preview {
    ChatView(chatRoom: mockChatRoom)
        .environmentObject(WebSocketManager())
        .environmentObject(UserViewModel())
}
