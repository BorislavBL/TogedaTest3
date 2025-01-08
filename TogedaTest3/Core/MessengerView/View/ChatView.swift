//
//  ChatView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.23.
//

import SwiftUI
import Kingfisher

enum RefreshCases {
    case loaded
    case loading
    case done
}

struct ChatView: View {
    @State private var messageText = ""
    @State private var isInitialLoad = true
    @State private var Init = true
    @StateObject var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    var chatRoom: Components.Schemas.ChatRoomDto
    @State var shouldNotScrollToBottom: Bool = false
    @EnvironmentObject var chatManager: WebSocketManager
    @EnvironmentObject var userVm: UserViewModel
    @EnvironmentObject var navManager: NavigationManager
    @State var isChatActive: Bool = false
    @State var atBottom: Bool = false
    @State var activateArrow: Bool = false
    //    @StateObject private var keyboard = KeyboardResponder()
    @State var recPadding: CGFloat = 60
    @State var setDateOnLeave = Date()
    @State private var keyboardHeight: CGFloat = 0
    @State private var polishedKeyboardHeight: CGFloat = 0
    @State var currentUsersMessage = false
    @State private var inputHeight: CGFloat = 30
    @State private var lastMessageIdBeforeLoading: String?
    @State private var refresh: RefreshCases = .done
    @State private var otherUser: Components.Schemas.UserInfoDto?
    
    var body: some View {
        ZStack(alignment: .top){
            VStack(spacing: 0) {
                navbar()
                if !Init {
                    ScrollViewReader{ proxy in
                        ScrollView{
                            LazyVStack{
                                if let currentUser = userVm.currentUser{
                                    
                                    if refresh == .loading {
                                        ProgressView() // Loading indicator while refreshing
                                            .frame(height: 40)
                                    }
                                    
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
                                                            nextMessage: nextMessage(forIndex: index), prevMessage: prevMessage(forIndex: index), currentUserId: currentUser.id, chatRoom: chatRoom, vm: viewModel)
                                            
                                        }
                                        .id(message.id)
                                        
                                    }
                                    
                                    if chatManager.messages.last?.sender.id == currentUser.id {
                                        Text("Sent")
                                            .font(.footnote)
                                            .foregroundStyle(.gray)
                                            .frame(maxWidth:.infinity, alignment: .trailing)
                                            .padding(.horizontal)
                                    }
                                    
                                    Color.clear
                                        .frame(height: recPadding)
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
                            .background(
                                GeometryReader { geo -> Color in
                                    // Detect if we are at the bottom by comparing scroll position and content size
                                    DispatchQueue.main.async {
                                        let minY = geo.frame(in: .global).minY
                                        let threshold = 250.0
                                        if minY >= threshold && self.refresh == .done && !shouldNotScrollToBottom && !isInitialLoad{
                                            self.refresh = .loading
                                            if chatManager.messages.count > 0 {
                                                self.lastMessageIdBeforeLoading = chatManager.messages[0].id
                                            }
                                            Task {
                                                defer{
                                                    Task{
                                                        //                                                    try await Task.sleep(nanoseconds: 1_000_000_000)
                                                        self.refresh = .loaded
                                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                    }
                                                }
                                                do {
                                                    try await chatManager.getMessages(chatId: chatRoom.id)
                                                } catch {
                                                    print("Failed to get messages: \(error)")
                                                }
                                            }
                                        } else if self.refresh == .loaded && minY < threshold {
                                            self.refresh = .done
                                        }
                                    }
                                    return Color.clear
                                }
                            )
                            
                        }
                        //                    .refreshable {
                        //                        lastMessageIdBeforeLoading = chatManager.messages[0].id
                        //                        Task {
                        //                            do {
                        //                                try await chatManager.getMessages(chatId: chatRoom.id)
                        //                            } catch {
                        //                                print("Failed to get messages: \(error)")
                        //                            }
                        //                        }
                        //                    }
                        .scrollDismissesKeyboard(.interactively)
//                        .defaultScrollAnchor(.bottom)
                        .scrollIndicators(.hidden)
                        .ignoresSafeArea(.keyboard, edges: .all)                    //                    .padding(.top, 86)
                        .onChange(of: chatManager.messages) { oldValue, newValue in
                            if isInitialLoad {
//                                proxy.scrollTo(chatManager.messages.last?.id, anchor:.top)
                                proxy.scrollTo("Bottom", anchor:.bottom)
                            }
                            if let messageId = lastMessageIdBeforeLoading {
                                proxy.scrollTo(messageId, anchor:.top)
                                self.lastMessageIdBeforeLoading = nil
                            }
                            if !shouldNotScrollToBottom && !isInitialLoad && atBottom {
                                withAnimation(.spring()) {
                                    proxy.scrollTo("Bottom", anchor:.bottom)
                                }
                            } else if currentUsersMessage {
                                print("on that one")
                                
                                withAnimation(.spring()) {
                                    proxy.scrollTo("Bottom", anchor:.bottom)
                                }
                                
                                currentUsersMessage = false
                            }
                            
                            shouldNotScrollToBottom = false
                        }
                        .onChange(of: keyboardHeight) { oldValue, newValue in
                            print("Keyboard H:", keyboardHeight, oldValue, newValue)
                            if keyboardHeight > 0{
                                if oldValue == 0 {
                                    let min = min(oldValue, newValue)
                                    let max = max(oldValue, newValue)
                                    if min > max - 100 {
                                        polishedKeyboardHeight = min
                                        recPadding = min + inputHeight
                                    } else {
                                        polishedKeyboardHeight = max
                                        recPadding = max + inputHeight
                                    }
                                } else {
                                    polishedKeyboardHeight = newValue
                                    recPadding = newValue + inputHeight
                                }
                                if atBottom {
                                    withAnimation() {
                                        proxy.scrollTo("Bottom", anchor:.bottom)
                                    }
                                }
                            } else {
                                polishedKeyboardHeight = 0
                                recPadding = keyboardHeight > 0 ? inputHeight : 60
                            }
                        }
                        .overlay(alignment:.bottomTrailing){
                            if activateArrow {
                                Button{
                                    withAnimation() {
                                        proxy.scrollTo("Bottom", anchor:.bottom)
                                    }
                                    
                                    //                                activateArrow = false
                                } label:{
                                    Image(systemName: "arrow.down")
                                        .padding()
                                        .background(.bar)
                                        .clipShape(Circle())
                                }
                                .padding(.bottom, keyboardHeight > 0 ? inputHeight + 40 : 70)
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }

            
            VStack{
                Spacer()
                if let otherUser = self.otherUser, otherUser.currentFriendshipStatus != .FRIENDS, chatRoom._type == .FRIENDS {
                    HStack{
                        Image(systemName: "lock.fill")
                            .opacity(0.5)
                        Text("Oops! You can only message people who are on your friends list.")
                            .bold()
                            .font(.footnote)
                            .opacity(0.5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(8)
                    .background(.bar)
                    
                    
                    
                } else {
                    MessageInputView(messageText: $messageText, isChatActive: $isChatActive, viewModel: viewModel) {
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
                            
                            self.currentUsersMessage = true
                        }
                    }
                    .padding(.top, 8)
                    .background(.bar)
                    .background(GeometryReader { geometry in
                        Color.clear
                            .onChange(of: messageText) {
                                // Adjust height based on TextEditor's content
                                self.inputHeight = max(30, geometry.size.height - 30) // minimum height of 40
                                if keyboardHeight > 0 {
                                    recPadding = polishedKeyboardHeight + inputHeight
                                }
                            }
                    })
                }
                
                
                //                MessageInputView(messageText: $messageText, isActive: $isChatActive, viewModel: viewModel) {
                //                    if let currentUser = userVm.currentUser {
                //                        if let uiImage = viewModel.messageImage {
                //                            Task {
                //                                if let imageURL = await viewModel.uploadImageAsync(uiImage: uiImage) {
                //                                    chatManager.sendMessage(senderId: currentUser.id, chatId: chatRoom.id, content: imageURL, type: .IMAGE)
                //                                    messageText = ""
                //                                    viewModel.messageImage = nil
                //                                }
                //                            }
                //                        }
                //                        else if !messageText.isEmpty {
                //                            chatManager.sendMessage(senderId: currentUser.id, chatId: chatRoom.id, content: messageText , type: .NORMAL)
                //                            messageText = ""
                //                        }
                //                    }
                //                }
                //                .padding(.top, 8)
                //                .background(.bar)
                
            }

            
            if viewModel.isImageView, let image = viewModel.selectedImage{
                ImageViewer(isActive: $viewModel.isImageView, image: image)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            onActive()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            Task {
                do{
                    try await chatManager.setChatAsLeft(chatId: chatRoom.id)
                } catch {
                    print(error)
                }
            }
            
            setDateOnLeave = Date()
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
        .keyboardHeight($keyboardHeight)
        
        
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
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
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
                                    HStack(spacing: 5){
                                        Text("\(chatRoom.previewMembers[0].firstName) \(chatRoom.previewMembers[0].lastName)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        if chatRoom.previewMembers[0].userRole == .AMBASSADOR {
                                            AmbassadorSealMini()
                                        } else if chatRoom.previewMembers[0].userRole == .PARTNER {
                                            PartnerSealMini()
                                        }
                                    }
                                }
                            }
                        }
                    }
                case .GROUP:
                    if chatRoom.previewMembers.count > 1 {
                        Button{
                            navManager.selectionPath.append(.groupSettingsView(chatroom: chatRoom))
                        } label: {
                            HStack(alignment: .center){
                                if let image = chatRoom.image {
                                    KFImage(URL(string: image))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 30, height: 30)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                } else if chatRoom.previewMembers.count > 1 {
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
                                
                                if let title = chatRoom.title {
                                    Text("\(title)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                } else if chatRoom.previewMembers.count > 1 {
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
                    
                    if chatRoom._type == .FRIENDS {
                        group.addTask {
                            do{
                                if let result = try await APIClient.shared.getUserInfo(userId: chatRoom.previewMembers[0].id) {
                                    DispatchQueue.main.async{
                                        otherUser = result
                                    }
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func onActive() {
        Task{
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    do {
                        if let date = await chatManager.messages.last?.createdAt, let response = try await APIClient.shared.updateChatMessages(chatId: chatRoom.id, lastTimestamp: chatManager.messages.count > 0 ? date : setDateOnLeave) {
                            print("Messages triggered")
                            print("response", response.data)
                            DispatchQueue.main.async {
                                chatManager.chatMessagesCheck(messages: response.data, chatId: chatRoom.id)
                            }
                            
                        }
                    } catch {
                        // Handle the error if needed
                        print("Error updating chat rooms: \(error)")
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
    
    
    
    func nextMessage(forIndex index: Int) -> Components.Schemas.ReceivedChatMessageDto? {
        if index > 0 {
            return index != chatManager.messages.count - 1 ? chatManager.messages[index + 1] : nil
        }
        return nil
    }
    
    func prevMessage(forIndex index: Int) -> Components.Schemas.ReceivedChatMessageDto? {
        if index > 0 && index <= chatManager.messages.count - 1 {
            return chatManager.messages[index - 1]
        }
        return nil
    }
    
}

#Preview {
    ChatView(chatRoom: mockChatRoom)
        .environmentObject(WebSocketManager())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
    
}
