////
////  WebSocketManager.swift
////  TogedaTest3
////
////  Created by Borislav Lorinkov on 23.07.24.
////

import SwiftUI
import SwiftStomp

class WebSocketManager: ObservableObject, SwiftStompDelegate {
    @Published var allChatRooms: [Components.Schemas.ChatRoomDto] = []
//    {
//        didSet {
//            self.unreadMessagesCount = allChatRooms.filter { !$0.read }.count
//        }
//    }
    @Published private var previousAllChatRooms: [Components.Schemas.ChatRoomDto] = []
    @Published var inboxChatsState: LoadingCases = .loading
    @Published var chatPage: Int32 = 0
    @Published var chatSize: Int32 = 30
    @Published var lastChatPage = true
    @Published var isLoadingChats: LoadingCases = .noResults
    @Published var unreadMessagesCount = 0
    @Published var inCurrentChatroom: Components.Schemas.ChatRoomDto?
        
    //    struct ReceivedChatMessageExtension: Hashable {
    //        var message: Components.Schemas.ReceivedChatMessageDto
    //        var post: Components.Schemas.PostResponseDto?
    //        var club: Components.Schemas.ClubDto?
    //    }
    //
    //    func receivedChatMessageConverter(
    //        _ message: Components.Schemas.ReceivedChatMessageDto,
    //        post: Components.Schemas.PostResponseDto? = nil,
    //        club: Components.Schemas.ClubDto? = nil) -> ReceivedChatMessageExtension{
    //        return .init(message: message, post: post, club: club)
    //    }
    
    @Published var messages: [Components.Schemas.ReceivedChatMessageDto] = []
    @Published var lastMessagesPage: Bool = true
    @Published var messagesPage: Int32 = 0
    @Published var messagesSize: Int32 = 30
    @Published var chatRoomId: String?
    
    @Published private var retryCount = 0
    @Published private var maxRetryAttempts = 5
    @Published private var initialRetryDelay: TimeInterval = 2.0
    
    @Published var swiftStomp: SwiftStomp!
    @Published var currentUserId: String? {
        didSet {
            connectToCurrentUser(oldValue: oldValue)
        }
    }
    @Published var isReconnecting = false
    @Published var showSatatusDisconnectedError: Bool = false
    
    @Published var notificationsList: [Components.Schemas.NotificationDto] = []
    @Published var newNotification: Components.Schemas.NotificationDto?
    @Published var page: Int32 = 0
    @Published var size: Int32 = 30
    @Published var count: Int64 = 0
    @Published var lastPage: Bool = true
    @Published var isConnected = false
    @Published var loadingState: LoadingCases = .loading
    @Published var isLoadingRect: LoadingCases = .noResults
    @Published var unreadNotificationsCount: Int = 0

    
    init(){
        print("The websokcet init is triggered <------------------>")
        websocketInit()
    }
    
    struct ChatUpdates: Codable, Hashable {
        var chatRoomId: String
    }
    
    struct ChatLikes: Codable, Hashable {
        var id: String?
        var likeCount: Int32?
    }
    
    struct Unsent: Codable, Hashable {
        var id: String?
    }
    
    struct Edited: Codable, Hashable {
        var id: String?
        var content: String?
    }
    
}

extension WebSocketManager {
    
    func reconnectWithNewToken() {
        guard !isReconnecting else {
            print("Reconnection already in progress, skipping.")
            return
        }
        DispatchQueue.main.async {
            self.isReconnecting = true
        }
        print("-------------------Reconect with new Token------------------")
        if let token = AuthService.shared.getAccessToken() {
            //            if isConnected {
            self.disconnect() // Disconnect current connection
            //            }
            let url = URL(string: TogedaMainLinks.websocketURL)!
            self.swiftStomp = SwiftStomp(host: url, headers: ["Authorization": "Bearer \(token)"]) // Reinitialize with new token
            self.swiftStomp.delegate = self // Reset delegate
            self.swiftStomp.autoReconnect = true // Auto reconnect on error or cancel
            self.swiftStomp.enableLogging = false
            self.swiftStomp.connect()
            print("Websocket reconnected!")
        }
    }
    
    private func websocketInit() {
        if let token = AuthService.shared.getAccessToken() {
            print("-------------------Websocket Init------------------")
            let url = URL(string: TogedaMainLinks.websocketURL)! // Ensure using 'wss' or 'ws' schema
            //            self.swiftStomp = SwiftStomp(host: url, headers: ["Authorization" : "Bearer \(retryCount >= 2 ? token : "haaa")"]) //< Create instance
            self.swiftStomp = SwiftStomp(host: url, headers: ["Authorization" : "Bearer \(token)"]) //< Create instance
            self.swiftStomp.delegate = self //< Set delegate
            self.swiftStomp.autoReconnect = true //< Auto reconnect on error or cancel
            self.swiftStomp.enableLogging = false
            
            self.swiftStomp.connect()
            DispatchQueue.main.async {
                self.isConnected = true
            }
        }
    }
    
    func connect() {
        self.swiftStomp.connect() //< Connect
    }
    
    func recconect() {
        self.disconnect()
        self.connect()
    }
    
    
    func reconnectWithExponentialBackoff() {
        guard retryCount < maxRetryAttempts else {
            print("Max reconnection attempts reached. Stopping retries.")
            return
        }
        
        let delay = initialRetryDelay * pow(2.0, Double(retryCount))
        print("Attempting to reconnect in \(delay) seconds...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.retryCount += 1
            self.websocketInit()
        }
    }
    
    func subscribeToAllConnections(id: String) {
        swiftStomp.subscribe(to: "/user/\(id)/queue/messages", mode: .clientIndividual)
        swiftStomp.subscribe(to: "/user/\(id)/queue/notifications", mode: .clientIndividual)
        swiftStomp.subscribe(to: "/user/\(id)/queue/updates", mode: .clientIndividual)
        swiftStomp.subscribe(to: "/user/\(id)/queue/message/likes", mode: .clientIndividual)
        swiftStomp.subscribe(to: "/user/\(id)/queue/message/unsent", mode: .clientIndividual)
        swiftStomp.subscribe(to: "/user/\(id)/queue/message/edited", mode: .clientIndividual)
    }
    
    func unsubscribeToAllConnections(id: String) {
        swiftStomp.unsubscribe(from: "/user/\(id)/queue/messages")
        swiftStomp.unsubscribe(from: "/user/\(id)/queue/notifications")
        swiftStomp.unsubscribe(from: "/user/\(id)/queue/updates")
        swiftStomp.unsubscribe(from: "/user/\(id)/queue/message/likes")
        swiftStomp.unsubscribe(from: "/user/\(id)/queue/message/unsent")
        swiftStomp.unsubscribe(from: "/user/\(id)/queue/message/edited")
    }
    
    func disconnect() {
        print("Disconnected websocket")
        if let id = self.currentUserId{
            unsubscribeToAllConnections(id: id)
            
        }
        self.swiftStomp.disableAutoPing()
        self.swiftStomp.disconnect()
    }
    
    func connectToCurrentUser(oldValue: String?) {
        if self.swiftStomp.connectionStatus == .fullyConnected {
            if let id = self.currentUserId{
                print(id)
                unsubscribeToAllConnections(id: oldValue ?? id)
                
                subscribeToAllConnections(id: id)
                
                
            }
        }
    }
    
    func connectionStatus() {
        switch self.swiftStomp.connectionStatus {
        case .connecting:
            print("Connecting to the server...")
        case .socketConnected:
            print("Scoket is connected but STOMP as sub-protocol is not connected yet.")
        case .fullyConnected:
            DispatchQueue.main.async {
                self.showSatatusDisconnectedError = false

            }
            print("Both socket and STOMP is connected. Ready for messaging...")
        case .socketDisconnected:
            print("Socket is disconnected")
        }
    }
    
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        switch connectType {
        case .toSocketEndpoint:
            print("Connected to socket endpoint")
        case .toStomp:
            self.swiftStomp.enableAutoPing(pingInterval: 10)
            print("Connected to STOMP")
            DispatchQueue.main.async {
                self.retryCount = 0
                self.isReconnecting = false // Reset the flag
                withAnimation() {
                    self.showSatatusDisconnectedError = false
                }
            }
            
            connectionStatus()
            
            if let id = self.currentUserId{
                subscribeToAllConnections(id: id)
            }
            
        }
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        if disconnectType == .fromSocket {
            print("Socket disconnected. Disconnect completed")
        } else if disconnectType == .fromStomp {
            print("Client disconnected from STOMP but socket is still connected!")
            DispatchQueue.main.async {
                self.isConnected = false
                self.showSatatusDisconnectedError = true

            }
        }
    }
    
    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
        do {
            if destination.hasSuffix("/messages") {
                if let message = message as? String, let jsonData = message.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    print("JsonData:", message)
                    let messageData = try decoder.decode(Components.Schemas.ReceivedChatMessageDto.self, from: jsonData)
                    chatRoomCheckWithMessage(messageData: messageData)
                    
                    if let chatRoomId, messageData.chatId == chatRoomId {
                        DispatchQueue.main.async {
                            //                            if let message = self.messages.last {
                            //                                if message.id != messageData.id{
                            //                                    self.messages.append(messageData)
                            //                                }
                            //                            } else {
                            //                                self.messages.append(messageData)
                            //                            }
                            
                            self.messages.removeAll(where: {$0.id == messageData.id})
                            self.messages.append(messageData)
                            
//                            print(messageData.status?.rawValue)
                            
                        }
                    }
                } else {
                    print("The message can't be converted into a data!")
                }
            } else if destination.hasSuffix("/notifications") {
                
                
                if let message = message as? String, let jsonData = message.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let notificationData = try decoder.decode(Components.Schemas.NotificationDto.self, from: jsonData)
                    
                    DispatchQueue.main.async {
                        self.addNotification(newNotification: notificationData)
                        self.newNotification = notificationData
                        self.unreadNotificationsCount += 1
                    }
                }
            } else if destination.hasSuffix("/message/likes") {
                if let message = message as? String, let jsonData = message.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let data = try decoder.decode(ChatLikes.self, from: jsonData)
                    DispatchQueue.main.async {
                        if let index = self.messages.firstIndex(where: {$0.id == data.id}) {
                            self.messages[index].likeCount = data.likeCount
                        }
                    }
                }
            } else if destination.hasSuffix("/message/unsent") {
                if let message = message as? String, let jsonData = message.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let data = try decoder.decode(Unsent.self, from: jsonData)
                    DispatchQueue.main.async {
                        if let index = self.messages.firstIndex(where: {$0.id == data.id}) {
                            self.messages[index].isUnsent = true
                        }
                    }
                }
            } else if destination.hasSuffix("/updates") {
                if let message = message as? String, let jsonData = message.data(using: .utf8) {
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let data = try decoder.decode(ChatUpdates.self, from: jsonData)
                    DispatchQueue.main.async {
                        self.allChatRooms.removeAll(where: {$0.id == data.chatRoomId})
                    }
                }
            } else if destination.hasSuffix("message/edited") {
                if let message = message as? String, let jsonData = message.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let data = try decoder.decode(Edited.self, from: jsonData)
                    DispatchQueue.main.async {
                        if let index = self.messages.firstIndex(where: {$0.id == data.id}), let text = data.content {
                            self.messages[index].content = text
                            self.messages[index].isEdited = true
                        }
                    }
                }
            }
        } catch {
            print("Message error:", error)
        }
        
        //        if let message = message as? String {
        //            print("Message with id `\(messageId)` received at destination `\(destination)`:\n\(message)")
        //
        //        } else if let message = message as? Data {
        //            print("Data message with id `\(messageId)` and binary length `\(message.count)` received at destination `\(destination)`")
        //        }
        //
        
    }
    
    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        print("Receipt with id `\(receiptId)` received")
    }
    
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        if type == .fromSocket {
            print("Socket error occurred! [\(briefDescription)]")
        } else if type == .fromStomp {
            print("STOMP error occurred! [\(briefDescription)] : \(String(describing: fullDescription))")
        } else {
            print("Unknown error occurred!")
        }
        
        print("STOMP error occurred! [\(briefDescription)] : \(String(describing: fullDescription))")
        
        DispatchQueue.main.async {
            self.isReconnecting = false // Reset the flag on error
            if swiftStomp.connectionStatus == .socketDisconnected {
                self.showSatatusDisconnectedError = true
            }
        }
    }
    
    func onSocketEvent(eventName: String, description: String) {
        print("Socket event occurred: \(eventName) => \(description)")
    }
    
    func sendMessage(sender: Components.Schemas.MiniUser, chatId: String, content: String, type: Components.Schemas.ReceivedChatMessageDto.contentTypePayload, replyToMessage: Components.Schemas.ReceivedChatMessageDto?) {
        let modifiedContent = limitConsecutiveReturns(in: content)
        let id = UUID().uuidString.lowercased()
        var chatMessage = ChatMessages(id: id, senderId: sender.id, chatId: chatId, content: modifiedContent, contentType: type.rawValue)
        var sendingMessage = Components.Schemas.ReceivedChatMessageDto(id: id, chatId: chatId, sender: sender, content: content, contentType: type, createdAt: Date(), status: .SENDING)
        
        if let reply = replyToMessage {
            let replyTo = Components.Schemas.ReplyToMessage(id: reply.id, sender: sender, contentType: .init(rawValue: reply.contentType.rawValue) ?? .NORMAL, content: reply.content, isUnsent: reply.isUnsent)
            chatMessage.replyToMessageId = reply.id
            sendingMessage.replyTo = replyTo
        }
        
        DispatchQueue.main.async{
            self.messages.append(sendingMessage)
        }
        
        do {
            let jsonData = try JSONEncoder().encode(chatMessage)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                swiftStomp.send(body: jsonString, to: "/app/chat", headers: ["content-type":"application/json"])
            }
        } catch {
            print("Error encoding message: \(error)")
        }
    }
}

extension WebSocketManager {
    func calculateUnreadMessagesCount(prevChatroom: [Components.Schemas.ChatRoomDto]) {
        let oldUnreadCount = prevChatroom.filter { !$0.read }.count
        let newUnreadCount = allChatRooms.filter { !$0.read }.count
        
        let diff = newUnreadCount - oldUnreadCount
        self.unreadMessagesCount += diff

        // Optional: If you want to guarantee it doesn't go negative
        if unreadMessagesCount < 0 {
            unreadMessagesCount = 0
        }
    }
    
    func chatRoomCheckWithMessage(messageData: Components.Schemas.ReceivedChatMessageDto) {
        DispatchQueue.main.async {
            let prevChatroom = self.allChatRooms
            
            if let index = self.allChatRooms.firstIndex(where: { $0.id == messageData.chatId }) {
                // Update the chat room's last message and timestamp

                
                var chatRoom = self.allChatRooms[index]
                chatRoom.latestMessage = messageData
                chatRoom.latestMessageTimestamp = messageData.createdAt
                // Remove the chat room from its current position
                self.allChatRooms.remove(at: index)
                
                //the unread messages count checker - later has to be replaced when the read of messages is implemented
                if let c_chatroom = self.inCurrentChatroom, c_chatroom.id == chatRoom.id {
                    chatRoom.read = true
                } else {
                    chatRoom.read = false
                }
                // Insert the chat room at the top of the list
                self.allChatRooms.insert(chatRoom, at: 0)
            } else {
                Task{
                    var attempt = 0
                    var chatRoom: Components.Schemas.ChatRoomDto?
                    while attempt < 2 {
                        do {
                            chatRoom = try await APIClient.shared.getChat(chatId: messageData.chatId)
                            if let room = chatRoom {
                                if let latestMessage = room.latestMessage, !latestMessage.content.isEmpty {
                                    DispatchQueue.main.async {
                                        self.allChatRooms.insert(room, at: 0)
                                    }
                                    break
                                } else if attempt == 1 {
                                    chatRoom?.latestMessage = messageData
                                    if let room_ = chatRoom {
                                        DispatchQueue.main.async {
                                            self.allChatRooms.insert(room_, at: 0)
                                        }
                                        break
                                    }
                                }
                            }
                        } catch {
                            print("Failed to fetch chatRoom: \(error)")
                            break // Exit if an error occurs
                        }
                        
                        attempt += 1
                        
                        // Delay for 5 seconds if this was the first attempt
                        if attempt == 1 {
                            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                        }
                    }
                }
            }
            
            self.calculateUnreadMessagesCount(prevChatroom: prevChatroom)
        }
    }
    
    //    func chatRoomCheck(chatRoom: Components.Schemas.ChatRoomDto) {
    //        if let index = allChatRooms.firstIndex(where: { $0.id == chatRoom.id }) {
    //            DispatchQueue.main.async {
    //                print("triggered chat")
    //                // Remove the chat room from its current position
    //                self.allChatRooms.remove(at: index)
    //                // Insert the chat room at the top of the list
    //                self.allChatRooms.insert(chatRoom, at: 0)
    //            }
    //        } else {
    //            DispatchQueue.main.async {
    //                self.allChatRooms.insert(chatRoom, at: 0)
    //            }
    //        }
    //    }
    func chatRoomCheck(chatRoom: Components.Schemas.ChatRoomDto) {
        DispatchQueue.main.async {
            self.allChatRooms.removeAll(where: { $0.id == chatRoom.id})
            self.allChatRooms.insert(chatRoom, at: 0)
            
        }
    }
    
    func chatRoomsCheck(chatRooms: [Components.Schemas.ChatRoomDto]) {
        if chatRooms.count < 50 {
            for chatRoom in chatRooms.reversed() {
                chatRoomCheck(chatRoom: chatRoom)
            }
        }  else {
            Task{
                await withCheckedContinuation { continuation in
                    DispatchQueue.main.async{
                        self.allChatRooms = []
                        self.chatPage = 0
                        continuation.resume()
                    }
                }
                try await getAllChats()
            }
        }
    }
    
    func editMessage(messageId: String, newMessage: String) {
        Task{
            if let response = try await APIClient.shared.editMessage(messageId: messageId, text: newMessage){

            }
        }
        
    }
    
    func chatMessageCheck(message: Components.Schemas.ReceivedChatMessageDto) {
        DispatchQueue.main.async {
            self.messages.removeAll(where: { msg in
                if msg.id == message.id && msg.content == message.content && msg.createdAt == message.createdAt {
                    return true
                }
                return false
            })
            self.messages.append(message)
        }
    }
    
    func limitConsecutiveReturns(in text: String) -> String {
        // First, handle trailing newlines without text (remove them)
        let trimmedText = text.replacingOccurrences(of: "\n+$", with: "", options: .regularExpression)
        
        // Then, limit consecutive newlines to 3 if they exist inside the text
        let regexPattern = "\n{4,}"  // Matches 4 or more consecutive newlines
        let modifiedText = trimmedText.replacingOccurrences(of: regexPattern, with: "\n\n\n", options: .regularExpression)
        
        return modifiedText
    }
    
    func chatMessagesCheck(messages: [Components.Schemas.ReceivedChatMessageDto], chatId: String) {
        if messages.count < 150 {
            for message in messages {
                chatMessageCheck(message: message)
            }
        } else {
            Task{
                await withCheckedContinuation { continuation in
                    DispatchQueue.main.async{
                        self.messages = []
                        self.lastMessagesPage = true
                        self.messagesPage = 0
                        continuation.resume()
                    }
                }
                try await getMessages(chatId: chatId)
            }
        }
    }
    
    
    func getAllChats() async throws {
        DispatchQueue.main.async{
            if self.allChatRooms.count >= 0 {
                self.inboxChatsState = .loading
            }
        }
        if let response = try await APIClient.shared.allChats(page: chatPage, size: chatSize) {
            DispatchQueue.main.async{
                let newResponse = response.data
                let existingResponseIDs = Set(self.allChatRooms.suffix(30).map { $0.id })
                let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                
                self.allChatRooms += uniqueNewResponse
                self.lastChatPage = response.lastPage
                self.chatPage += 1
                
                if response.listCount > 0 {
                    self.inboxChatsState = .loaded
                } else {
                    self.inboxChatsState = .noResults
                }
                self.isLoadingChats = .loaded
            }
        }
        
    }
    
    func messagesToDefault() {
        DispatchQueue.main.async{
            self.chatRoomId = nil
            self.messages = []
            self.lastMessagesPage = true
            self.messagesPage = 0
        }
    }
    
    func getMessages(chatId: String) async throws {
        if let response = try await APIClient.shared.chatMessages(chatId: chatId, page: messagesPage, size: messagesSize) {
            DispatchQueue.main.async{
                let newResponse = response.data
                let existingResponseIDs = Set(self.messages.prefix(30).map { $0.id })
                let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                
                self.chatRoomId = chatId
                self.messages.insert(contentsOf: uniqueNewResponse, at: 0)
                self.lastMessagesPage = response.lastPage
                if !response.lastPage{
                    self.messagesPage += 1
                }
            }
        }
    }
    
    func getUnreadMessagesCount() async throws {
        if let response = try await APIClient.shared.unreadMessagesCount(){
            DispatchQueue.main.async{
                self.unreadMessagesCount = Int(response.number)
            }
        }
    }
    
    func setChatAsEntered(chatId: String) async throws {
        if (try await APIClient.shared.enterChat(chatId: chatId)) != nil {
            DispatchQueue.main.async{
                
                if let index = self.allChatRooms.firstIndex(where: { $0.id == chatId }) {
                    // Update the chat room's last message and timestamp
                    let prevChatrooms = self.allChatRooms
                    self.allChatRooms[index].read = true
                    self.calculateUnreadMessagesCount(prevChatroom: prevChatrooms)
                    
                }
            }
        }
    }
    
    func setChatAsLeft(chatId: String) async throws {
        if (try await APIClient.shared.leaveChat(chatId: chatId)) != nil {
        }
    }
}

extension WebSocketManager {
    func fetchInitialNotification(completion: @escaping (Bool) -> Void) async throws {
        do {
            if let response = try await APIClient.shared.notificationsList(page: page, size: size){
                DispatchQueue.main.async {
                    let newResponse = response.data
                    let existingResponseIDs = Set(self.notificationsList.suffix(30).map { $0.id })
                    let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                    
                    self.notificationsList += uniqueNewResponse
                    self.page += 1
                    self.count = response.listCount
                    self.lastPage = response.lastPage
                    self.loadingState = .loaded
                    self.isLoadingRect = .loaded
                    completion(true)
                    
                    if response.lastPage && self.notificationsList.count == 0{
                        self.loadingState = .noResults
                        self.isLoadingRect = .noResults
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.loadingState = .noResults
                    self.isLoadingRect = .loaded
                }
            }
        } catch {
            print("error:", error)
            completion(false)
            DispatchQueue.main.async {
                self.loadingState = .noResults
            }
        }
    }
    
    func unreadNotifications() async throws {
        if let notNumber = try await APIClient.shared.unreadNotificationsCount(){
            DispatchQueue.main.async {
                self.unreadNotificationsCount = Int(notNumber.number)
            }
        }
    }
    
    func addNotification(newNotification: Components.Schemas.NotificationDto) {
        if let not = newNotification.alertBodyAcceptedJoinRequest{
            switch not.forType {
            case .CLUB:
                if not.club != nil{
                    notificationsList.insert(newNotification, at: 0)
                }
            case .POST:
                if not.post != nil{
                    notificationsList.insert(newNotification, at: 0)
                }
            case .none: break
                
            }
        } else if let not = newNotification.alertBodyReceivedJoinRequest{
            switch not.forType {
            case .POST:
                if let post = not.post{
                    notificationsList.removeAll { notification in
                        if let not = notification.alertBodyReceivedJoinRequest, let newPost = not.post, newPost.id == post.id {
                            return true
                        } else {
                            return false
                        }
                    }
                    notificationsList.insert(newNotification, at: 0)
                }
            case .CLUB:
                if let club = not.club{
                    notificationsList.removeAll { notification in
                        if let not = notification.alertBodyReceivedJoinRequest, let newClub = not.club, newClub.id == club.id {
                            return true
                        } else {
                            return false
                        }
                    }
                    notificationsList.insert(newNotification, at: 0)
                }
            case .none: break
                
            }
        } else if newNotification.alertBodyFriendRequestReceived != nil{
            notificationsList.removeAll { $0.alertBodyFriendRequestReceived?.sender.id == newNotification.alertBodyFriendRequestReceived?.sender.id }
            notificationsList.insert(newNotification, at: 0)
        } else if newNotification.alertBodyReviewEndedPost != nil {
            notificationsList.removeAll { $0.alertBodyReviewEndedPost?.post.id == newNotification.alertBodyReviewEndedPost?.post.id }
            notificationsList.insert(newNotification, at: 0)
        } else if newNotification.alertBodyPostHasStarted != nil {
            notificationsList.insert(newNotification, at: 0)
        } else if newNotification.alertBodyFriendRequestAccepted != nil {
            notificationsList.removeAll { $0.alertBodyFriendRequestAccepted?.user.id == newNotification.alertBodyFriendRequestAccepted?.user.id }
            notificationsList.insert(newNotification, at: 0)
        } else if newNotification.alertBodyUserAddedToParticipants != nil {
            notificationsList.removeAll { $0.alertBodyFriendRequestAccepted?.user.id == newNotification.alertBodyFriendRequestAccepted?.user.id }
            notificationsList.insert(newNotification, at: 0)
        }  else if newNotification.alertBodyPostWasCreatedInClub != nil {
            notificationsList.removeAll { $0.alertBodyPostWasCreatedInClub == newNotification.alertBodyPostWasCreatedInClub}
            notificationsList.insert(newNotification, at: 0)
        } else {
            notificationsList.removeAll { $0.id == newNotification.id }
        }
    }
    
    func notificationCheck(notification: Components.Schemas.NotificationDto) {
        //        let range = min(count + 10, notificationsList.count)
        
        // Remove the notification with the same ID from the first 'range' elements
        DispatchQueue.main.async {
            self.notificationsList.removeAll(where: {$0.id == notification.id})
            self.notificationsList.insert(notification, at: 0)
        }
    }
    
    func printNotIds() {
        let array = notificationsList.map { not in
            return not.id
        }
        
    }
    
    func notificationsCheck(notifications: [Components.Schemas.NotificationDto]) {
        if notifications.count < 50 {
            for not in notifications.reversed() {
                notificationCheck(notification: not)
            }
        } else {
            Task{
                await withCheckedContinuation { continuation in
                    DispatchQueue.main.async{
                        self.notificationsList = []
                        self.page = 0
                        continuation.resume()
                    }
                }
                try await self.fetchInitialNotification(){_ in
                    
                }
            }
        }
    }
}
