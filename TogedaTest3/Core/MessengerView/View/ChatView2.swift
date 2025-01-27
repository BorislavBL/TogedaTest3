////
////  ChatView.swift
////  TogedaTest3
////
////  Created by Borislav Lorinkov on 15.11.23.
////
//
//import SwiftUI
//import Kingfisher
//
//struct ChatView2: View {
//    @State private var messageText = ""
//    @State private var isInitialLoad = true
//    @State private var Init = true
//    @StateObject var viewModel = ChatViewModel()
//    @Environment(\.dismiss) private var dismiss
//    var chatRoom: Components.Schemas.ChatRoomDto
//    @State var shouldNotScrollToBottom: Bool = false
//    @EnvironmentObject var chatManager: WebSocketManager
//    @EnvironmentObject var userVm: UserViewModel
//    @EnvironmentObject var navManager: NavigationManager
//    @State var isChatActive: Bool = false
//    @State var atBottom: Bool = false
//    @State var activateArrow: Bool = false
//    //    @StateObject private var keyboard = KeyboardResponder()
//    @State var recPadding: CGFloat = 60
//    @State var setDateOnLeave = Date()
//    @State private var keyboardHeight: CGFloat = 0
//    @State var keyboardUp: Bool = false
//    
//    
//    
//    var body: some View {
//        ScrollViewReader{ proxy in
//            navbar()
//            ScrollView(.vertical){
//                LazyVStack{
//                    if let currentUser = userVm.currentUser{
//                        
//                        if chatManager.messages.count == 0 && !Init{
//                            VStack{
//                                Text("Write a message to start the chat.")
//                                    .font(.body)
//                                    .fontWeight(.semibold)
//                                    .padding()
//                                    .normalTagRectangleStyle()
//                                    .padding()
//                            }
//                        }
//                        
//                        ForEach(chatManager.messages, id: \.id) { message in
//                            VStack{
//                                //                                                                    if index == 0 {
//                                //                                                                        Text("\(formatDateAndTime(date: message.createdAt))")
//                                //                                                                            .font(.footnote)
//                                //                                                                            .foregroundStyle(.gray)
//                                //                                                                            .padding(8)
//                                //                                                                    }
//                                //                                                                    else if index > 0, let date = Calendar.current.dateComponents([.minute], from: chatManager.messages[index - 1].createdAt, to: message.createdAt).minute, date > 30 {
//                                //                                                                        Text("\(formatDateAndTime(date: message.createdAt))")
//                                //                                                                            .font(.footnote)
//                                //                                                                            .foregroundStyle(.gray)
//                                //                                                                            .padding(8)
//                                //
//                                //                                                                    }
//                                
//                                ChatMessageCell(message: message,
//                                                nextMessage: nil, currentUserId: currentUser.id, chatRoom: chatRoom, vm: viewModel)
//                                
//                            }
//                            
//                            .id(message.id)
//                            
//                        }
//                        
//                        if chatManager.messages.last?.sender.id == currentUser.id {
//                            Text("Sent")
//                                .font(.footnote)
//                                .foregroundStyle(.gray)
//                                .frame(maxWidth:.infinity, alignment: .trailing)
//                                .padding(.horizontal)
//                        }
//                        
//                    }
//                }
//                .background(
//                    GeometryReader { geo -> Color in
//                        // Detect if we are at the bottom by comparing scroll position and content size
//                        DispatchQueue.main.async {
//                            let maxScrollY = geo.frame(in: .global).maxY
//                            let scrollViewHeight = UIScreen.main.bounds.height
//                            // If the maxY of the content is equal to or smaller than the screen height, we are at the bottom
//                            if maxScrollY <= scrollViewHeight + 10 {
//                                if !atBottom {
//                                    atBottom = true
//                                    activateArrow = false
//                                }
//                            } else {
//                                if atBottom {
//                                    atBottom = false
//                                    activateArrow = true
//                                }
//                            }
//                        }
//                        return Color.clear
//                    }
//                )
//                
//            }
//            .refreshable {
//                Task {
//                    do {
//                        try await chatManager.getMessages(chatId: chatRoom.id)
//                    } catch {
//                        print("Failed to get messages: \(error)")
//                    }
//                }
//            }
//            .scrollDismissesKeyboard(.interactively)
//            .defaultScrollAnchor(.bottom)
//            .scrollIndicators(.hidden)
//            //                    .ignoresSafeArea(.keyboard, edges: .all)
//            //                    .padding(.top, 86)
//            .onChange(of: chatManager.messages) { oldValue, newValue in
//                //                        if isInitialLoad {
//                //                            proxy.scrollTo("Bottom", anchor:.bottom)
//                //
//                //                        } else
//                if !shouldNotScrollToBottom && !isInitialLoad && atBottom {
//                    withAnimation(.easeIn) {
//                        proxy.scrollTo(chatManager.messages.last?.id, anchor: .bottom)
//                    }
//                }
//                //                else if newValue.last?.sender.id == userVm.currentUser?.id && !isInitialLoad {
//                //                    withAnimation(.easeIn) {
//                //                        proxy.scrollTo(chatManager.messages.last?.id, anchor: .bottom)
//                //                    }
//                //                }
//                
//                shouldNotScrollToBottom = false
//            }
//            .overlay(alignment:.bottomTrailing){
//                if activateArrow {
//                    Button{
//                        withAnimation(.easeIn) {
//                            proxy.scrollTo(chatManager.messages.last?.id, anchor: .bottom)
//                        }
//                        
//                        activateArrow = false
//                    } label:{
//                        Image(systemName: "arrow.down")
//                            .padding()
//                            .background(.bar)
//                            .clipShape(Circle())
//                    }
//                    .padding(.bottom, 5)
//                }
//            }
//            MessageInputView2(messageText: $messageText, isChatActive: $isChatActive, viewModel: viewModel, proxy: proxy) {
//                if let currentUser = userVm.currentUser {
//                    if let uiImage = viewModel.messageImage {
//                        Task {
//                            if let imageURL = await viewModel.uploadImageAsync(uiImage: uiImage) {
//                                chatManager.sendMessage(senderId: currentUser.id, chatId: chatRoom.id, content: imageURL, type: .IMAGE)
//                                messageText = ""
//                                viewModel.messageImage = nil
//                            }
//                        }
//                    }
//                    else if !messageText.isEmpty {
//                        chatManager.sendMessage(senderId: currentUser.id, chatId: chatRoom.id, content: messageText , type: .NORMAL)
//                        messageText = ""
//                    }
//                    
//                    if !atBottom {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
//                            withAnimation(.easeIn) {
//                                proxy.scrollTo(chatManager.messages.last?.id, anchor: .bottom)
//                            }
//                        }
//                    }
//                }
//            }
//            .padding(.top, 8)
//            .background(.bar)
//        }
//        .overlay {
//            if viewModel.isImageView, let image = viewModel.selectedImage{
//                ImageViewer(isActive: $viewModel.isImageView, image: image)
//            }
//        }
//        
//        //        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//        //            onActive()
//        //        }
//        //        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
//        //            Task {
//        //                do{
//        //                    try await chatManager.setChatAsLeft(chatId: chatRoom.id)
//        //                } catch {
//        //                    print(error)
//        //                }
//        //            }
//        //
//        //            setDateOnLeave = Date()
//        //        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(true)
//        .swipeBack()
//        .onAppear(){
//            print("Trigger Appear")
//            if Init{
//                onInit()
//            }
//        }
//        .onDisappear(){
//            print("Trigger Disappear")
//            Task {
//                do{
//                    try await chatManager.setChatAsLeft(chatId: chatRoom.id)
//                } catch {
//                    print(error)
//                }
//            }
//        }
//        //        .keyboardHeight($keyboardHeight)
//        
//        
//    }
//    
//    @ViewBuilder
//    func navbar() -> some View {
//        ZStack{
//            HStack{
//                Button(action: {dismiss()}) {
//                    Image(systemName: "chevron.left")
//                }
//                .padding(.trailing, 8)
//                
//                switch chatRoom._type {
//                case .CLUB:
//                    if let club = chatRoom.club{
//                        Button{
//                            Task{
//                                if let _club = try await APIClient.shared.getClub(clubID: club.id){
//                                    navManager.selectionPath.append(.club(_club))
//                                }
//                            }
//                        } label: {
//                            HStack{
//                                KFImage(URL(string: club.images[0]))
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 30, height: 30)
//                                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
//                                
//                                Text("\(club.title)")
//                            }
//                        }
//                    }
//                case .FRIENDS:
//                    if chatRoom.previewMembers.count > 0 {
//                        Button{
//                            navManager.selectionPath.append(.profile(chatRoom.previewMembers[0]))
//                        } label: {
//                            HStack{
//                                KFImage(URL(string: chatRoom.previewMembers[0].profilePhotos[0]))
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 30, height: 30)
//                                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
//                                
//                                if chatRoom.previewMembers.count > 0 {
//                                    Text("\(chatRoom.previewMembers[0].firstName) \(chatRoom.previewMembers[0].lastName)")
//                                        .font(.subheadline)
//                                        .fontWeight(.semibold)
//                                }
//                            }
//                        }
//                    }
//                case .GROUP:
//                    if chatRoom.previewMembers.count > 1 {
//                        Button{
//                            navManager.selectionPath.append(.chatParticipants(chatroom: chatRoom))
//                        } label: {
//                            HStack(alignment: .center){
//                                if chatRoom.previewMembers.count > 1 {
//                                    ZStack(alignment:.top){
//                                        
//                                        KFImage(URL(string: chatRoom.previewMembers[0].profilePhotos[0]))
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 2 * 30/3, height: 2 * 30/3)
//                                            .clipShape(Circle())
//                                            .overlay(
//                                                Circle()
//                                                    .stroke(Color("base"), lineWidth: 2)
//                                            )
//                                            .offset(y: -30/6)
//                                        
//                                        KFImage(URL(string: chatRoom.previewMembers[1].profilePhotos[0]))
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 2 * 30/3, height: 2 * 30/3)
//                                            .clipShape(Circle())
//                                            .overlay(
//                                                Circle()
//                                                    .stroke(Color("base"), lineWidth: 2)
//                                            )
//                                            .offset(x: 30/6, y: 30/6)
//                                        
//                                    }
//                                    .padding([.trailing, .bottom, .top], 30/3)
//                                }
//                                
//                                if chatRoom.previewMembers.count > 1 {
//                                    Text("\(chatRoom.previewMembers[0].firstName), \(chatRoom.previewMembers[1].firstName) Group")
//                                        .font(.subheadline)
//                                        .fontWeight(.semibold)
//                                }
//                            }
//                        }
//                    }
//                case .POST:
//                    if let post = chatRoom.post{
//                        Button{
//                            Task{
//                                if let _post = try await APIClient.shared.getEvent(postId: post.id){
//                                    navManager.selectionPath.append(.eventDetails(_post))
//                                }
//                            }
//                        } label: {
//                            HStack{
//                                KFImage(URL(string: post.images[0]))
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 30, height: 30)
//                                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
//                                
//                                if let post = chatRoom.post {
//                                    Text("\(post.title)")
//                                        .font(.subheadline)
//                                        .fontWeight(.semibold)
//                                }
//                            }
//                        }
//                    }
//                }
//                Spacer()
//            }
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//        .background(.bar)
//    }
//    
//    func onInit() {
//        Task{
//            defer {
//                Task{
//                    Init = false
//                    try await Task.sleep(nanoseconds: 1_000_000_000)
//                    isInitialLoad = false
//                }
//            }
//            await withCheckedContinuation { continuation in
//                chatManager.messages = []
//                chatManager.lastMessagesPage = true
//                chatManager.messagesPage = 0
//                continuation.resume()
//            }
//            Task{
//                await withTaskGroup(of: Void.self) { group in
//                    group.addTask {
//                        do{
//                            try await chatManager.getMessages(chatId: chatRoom.id)
//                        } catch {
//                            print(error)
//                        }
//                    }
//                    
//                    group.addTask {
//                        do{
//                            try await chatManager.setChatAsEntered(chatId: chatRoom.id)
//                        } catch {
//                            print(error)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func onActive() {
//        Task{
//            await withTaskGroup(of: Void.self) { group in
//                group.addTask {
//                    do {
//                        if let date = await chatManager.messages.last?.createdAt, let response = try await APIClient.shared.updateChatMessages(chatId: chatRoom.id, lastTimestamp: chatManager.messages.count > 0 ? date : setDateOnLeave) {
//                            print("Messages triggered")
//                            print("response", response.data)
//                            DispatchQueue.main.async {
//                                chatManager.chatMessagesCheck(messages: response.data, chatId: chatRoom.id)
//                            }
//                            
//                        }
//                    } catch {
//                        // Handle the error if needed
//                        print("Error updating chat rooms: \(error)")
//                    }
//                }
//                
//                group.addTask {
//                    do{
//                        try await chatManager.setChatAsEntered(chatId: chatRoom.id)
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//        }
//    }
//    
//    
//    
//    func nextMessage(forIndex index: Int) -> Components.Schemas.ReceivedChatMessageDto? {
//        if index > 0 {
//            return index != chatManager.messages.count - 1 ? chatManager.messages[index + 1] : nil
//        }
//        return nil
//    }
//    
//}
//
//#Preview {
//    ChatView2(chatRoom: mockChatRoom)
//        .environmentObject(WebSocketManager())
//        .environmentObject(UserViewModel())
//        .environmentObject(NavigationManager())
//    
//}
