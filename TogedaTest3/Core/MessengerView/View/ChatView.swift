//
//  ChatView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.23.
//

import SwiftUI

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
    
    var body: some View {
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
                                    }
                                    else if index > 0, let date = Calendar.current.dateComponents([.minute], from: chatManager.messages[index - 1].createdAt, to: message.createdAt).minute, date > 30 {
                                        Text("\(formatDateAndTime(date: message.createdAt))")
                                            .font(.footnote)
                                            .foregroundStyle(.gray)
                                    }

                                    ChatMessageCell(message: message,
                                                    nextMessage: nextMessage(forIndex: index), currentUserId: currentUser.id, chatRoom: chatRoom)
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
                        }
                    }
                    .padding(.vertical)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .frame(width: 0, height: 0)
                                .onChange(of: geo.frame(in: .global).minY) { oldMinY, newMinY in
                                    if newMinY >= 130 && !isLoading && !chatManager.lastMessagesPage && shouldStartLoading && !isInitialLoad {
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
                    if !shouldNotScrollToBottom && !isInitialLoad {
                        withAnimation(.spring()) {
                            proxy.scrollTo("Bottom", anchor:.bottom)
                        }
                    }
                    
                    shouldNotScrollToBottom = false
                }
                .onChange(of: isChatActive) { oldValue, newValue in
                    if newValue {
                        withAnimation(.spring()) {
                            proxy.scrollTo("Bottom", anchor:.bottom)
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            onInit()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
        .swipeBack()
        .onAppear(){
            onInit()
        }
        .onDisappear(){
            chatManager.messagesToDefault()
        }
        
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
