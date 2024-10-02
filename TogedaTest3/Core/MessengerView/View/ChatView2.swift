//
//  ChatView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.23.
//

import SwiftUI
import Kingfisher

struct ChatView2: View {

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
    @EnvironmentObject var navManager: NavigationManager
    @State var isChatActive: Bool = false
    @State var atBottom: Bool = false
    @State var activateArrow: Bool = false
    @StateObject private var keyboard = KeyboardResponder()
    
    
    var body: some View {
        ZStack(alignment: .top){
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
                                                        nextMessage: nextMessage(forIndex: index), currentUserId: currentUser.id, chatRoom: chatRoom, vm: viewModel)
                                    }
                                    
                                }
                                
                                if chatManager.messages.last?.sender.id == currentUser.id {
                                    Text("Sent")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .frame(maxWidth:.infinity, alignment: .trailing)
                                        .padding(.horizontal)
                                }
                                
                                Color.clear
                                    .frame(height: (keyboard.currentHeight > 0 ? keyboard.currentHeight + 40 : 60))
                                    .id("Bottom")
                                    .onAppear(){
                                        print("Appeared >")
                                        atBottom = true
                                        activateArrow = false
                                    }
                                    .onDisappear(){
                                        print("DisAppeared >")
                                        atBottom = false
                                        activateArrow = true
                                    }
                                    
                            }
                        }
                        .padding(.top, 86)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .frame(width: 0, height: 0)
                                    .onChange(of: geo.frame(in: .global).minY) { oldMinY, newMinY in
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
                    }
                    .onChange(of: isChatActive) { oldValue, newValue in
                        if newValue && atBottom {
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
                            .padding(.bottom, (keyboard.currentHeight > 0 ? keyboard.currentHeight + 40 : 70))
                        }
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                //            Spacer()
                
            VStack{
                navbar()
                
                Spacer()

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
                .padding(.top, 8)
                .background(.bar)
                
                

            }
            
            if viewModel.isImageView, let image = viewModel.selectedImage{
                ImageViewer(isActive: $viewModel.isImageView, image: image)
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            onInit()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            Task {
                do{
                    try await chatManager.setChatAsLeft(chatId: chatRoom.id)
                } catch {
                    print(error)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .swipeBack()
        .onAppear(){
            if Init{
                onInit()
            }
        }
        .onDisappear(){
            Task {
                do{
                    try await chatManager.setChatAsLeft(chatId: chatRoom.id)
                } catch {
                    print(error)
                }
            }
        }
        
        
        
    }
    
    @ViewBuilder
    func navbar() -> some View {
        ZStack{
            HStack{
                Button(action: {dismiss()}) {
                    Image(systemName: "chevron.left")
                }
                .padding(.trailing, 8)
                
                switch chatRoom._type {
                case .CLUB:
                    if let club = chatRoom.club{
                        Button{
                            Task{
                                if let _club = try await APIClient.shared.getClub(clubID: club.id){
                                    navManager.selectionPath.append(.club(_club))
                                }
                            }
                        } label: {
                            HStack{
                                KFImage(URL(string: club.images[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                
                                Text("\(club.title)")
                            }
                        }
                    }
                case .FRIENDS:
                    if chatRoom.previewMembers.count > 0 {
                        Button{
                            navManager.selectionPath.append(.profile(chatRoom.previewMembers[0]))
                        } label: {
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
                    }
                case .GROUP:
                    if chatRoom.previewMembers.count > 1 {
                        Button{
                            navManager.selectionPath.append(.chatParticipants(chatId: chatRoom.id))
                        } label: {
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
                    }
                case .POST:
                    if let post = chatRoom.post{
                        Button{
                            Task{
                                if let _post = try await APIClient.shared.getEvent(postId: post.id){
                                    navManager.selectionPath.append(.eventDetails(_post))
                                }
                            }
                        } label: {
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
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
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
            Task{
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        do{
                            try await chatManager.getMessages(chatId: chatRoom.id)
                        } catch {
                            print(error)
                        }
                    }
                    
                    group.addTask {
                        do{
                            try await chatManager.setChatAsEntered(chatId: chatRoom.id)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    
    func nextMessage(forIndex index: Int) -> Components.Schemas.ReceivedChatMessageDto? {
        if index > 0 {
            return index != chatManager.messages.count - 1 ? chatManager.messages[index + 1] : nil
        }
        return nil
    }
}

#Preview {
    ChatView2(chatRoom: mockChatRoom)
        .environmentObject(WebSocketManager())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())

}
