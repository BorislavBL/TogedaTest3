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
    @Published var chatPage: Int32 = 0
    @Published var chatSize: Int32 = 15
    @Published var lastChatPage = true
    
    @Published var messages: [Components.Schemas.ReceivedChatMessageDto] = []
    @Published var lastMessagesPage: Bool = true
    @Published var messagesPage: Int32 = 0
    @Published var messagesSize: Int32 = 30
    @Published var chatRoomId: String?
    
    @Published var swiftStomp: SwiftStomp!
    @Published var currentUserId: String?
    {
        didSet {
            connectToCurrentUser(oldValue: oldValue)
        }
    }
    
    @Published var notificationsList: [Components.Schemas.NotificationDto] = []
    @Published var newNotification: Components.Schemas.NotificationDto?
    @Published var page: Int32 = 0
    @Published var size: Int32 = 15
    @Published var count: Int64 = 0
    @Published var lastPage: Bool = true
    @Published var isConnected = false
    
    init(){
        websocketInit()
    }
    
}

extension WebSocketManager {
    
    func reconnectWithNewToken(_ token: String?) {
        guard let token = token else { return }
        if isConnected {
            swiftStomp.disconnect() // Disconnect current connection
        }
        let url = URL(string: "wss://api.togeda.net/ws")!
        self.swiftStomp = SwiftStomp(host: url, headers: ["Authorization": "Bearer \(token)"]) // Reinitialize with new token
        self.swiftStomp.delegate = self // Reset delegate
        self.swiftStomp.autoReconnect = true // Auto reconnect on error or cancel
        self.swiftStomp.enableLogging = false
        self.swiftStomp.connect()
    }
    
    func websocketInit() {
        if let token = AuthService.shared.getAccessToken() {
            let url = URL(string: "wss://api.togeda.net/ws")! // Ensure using 'wss' or 'ws' schema
            self.swiftStomp = SwiftStomp(host: url, headers: ["Authorization" : "Bearer \(token)"]) //< Create instance
            self.swiftStomp.delegate = self //< Set delegate
            self.swiftStomp.autoReconnect = true //< Auto reconnect on error or cancel
            self.swiftStomp.enableLogging = false
            
            self.swiftStomp.connect()
            self.isConnected = true
        }
    }
    
    func connect() {
        self.swiftStomp.connect() //< Connect
    }
    
    func disconnect() {
        print("Disconnected websocket")
        //        if !Init {
        if let id = self.currentUserId{
            swiftStomp.unsubscribe(from: "/user/\(id)/queue/messages")
            swiftStomp.unsubscribe(from: "/user/\(id)/queue/notifications")
        }
        //        }
        
        self.swiftStomp.disconnect()
    }
    
    func connectToCurrentUser(oldValue: String?) {
        if self.swiftStomp.connectionStatus == .fullyConnected {
            if let id = self.currentUserId{
                print(id)
                swiftStomp.unsubscribe(from: "/user/\(oldValue ?? id)/queue/messages")
                swiftStomp.unsubscribe(from: "/user/\(oldValue ?? id)/queue/notifications")
                swiftStomp.subscribe(to: "/user/\(id)/queue/messages", mode: .clientIndividual)
                swiftStomp.subscribe(to: "/user/\(id)/queue/notifications", mode: .clientIndividual)
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
            
            connectionStatus()
            
            if let id = self.currentUserId{
                swiftStomp.subscribe(to: "/user/\(id)/queue/messages", mode: .clientIndividual)
                swiftStomp.subscribe(to: "/user/\(id)/queue/notifications", mode: .clientIndividual)
            }
            
        }
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        if disconnectType == .fromSocket {
            print("Socket disconnected. Disconnect completed")
        } else if disconnectType == .fromStomp {
            print("Client disconnected from STOMP but socket is still connected!")
        }
    }
    
    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
        do {
            print("1")
            if destination.hasSuffix("/messages") {
                if let message = message as? String, let jsonData = message.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let messageData = try decoder.decode(Components.Schemas.ReceivedChatMessageDto.self, from: jsonData)
                    chatRoomCheckWithMessage(messageData: messageData)
                    
                    if let chatRoomId, messageData.chatId == chatRoomId {
                        DispatchQueue.main.async {
                            self.messages.append(messageData)
                        }
                    }
                } else {
                    print("The message can't be converted into a data!")
                }
            } else if destination.hasSuffix("/notifications") {
                print("2")
                
                if let message = message as? String, let jsonData = message.data(using: .utf8) {
                    print("3")
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let notificationData = try decoder.decode(Components.Schemas.NotificationDto.self, from: jsonData)

                    addNotification(newNotification: notificationData)
                    newNotification = notificationData
                }
            }
        } catch {
            print("Message error:", error)
        }
        
        if let message = message as? String {
            print("Message with id `\(messageId)` received at destination `\(destination)`:\n\(message)")
            
        } else if let message = message as? Data {
            print("Data message with id `\(messageId)` and binary length `\(message.count)` received at destination `\(destination)`")
        }
        
        
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
    }
    
    func onSocketEvent(eventName: String, description: String) {
        print("Socket event occurred: \(eventName) => \(description)")
    }
    
    func sendMessage(senderId: String, chatId: String, content: String, type: Components.Schemas.ReceivedChatMessageDto.contentTypePayload) {
        let chatMessage = ChatMessages(senderId: senderId, chatId: chatId, content: content, contentType: type.rawValue)
        do {
            let jsonData = try JSONEncoder().encode(chatMessage)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                swiftStomp.send(body: jsonString, to: "/app/chat", headers: ["content-type":"application/json"])
            }
        } catch {
            print("Error encoding message: \(error)")
        }
    }
}

extension WebSocketManager {
    func chatRoomCheckWithMessage(messageData: Components.Schemas.ReceivedChatMessageDto) {
        DispatchQueue.main.async {
            if let index = self.allChatRooms.firstIndex(where: { $0.id == messageData.chatId }) {
                // Update the chat room's last message and timestamp
                
                var chatRoom = self.allChatRooms[index]
                chatRoom.latestMessage = messageData
                chatRoom.latestMessageTimestamp = messageData.createdAt
                // Remove the chat room from its current position
                self.allChatRooms.remove(at: index)
                
                // Insert the chat room at the top of the list
                self.allChatRooms.insert(chatRoom, at: 0)
            }
            
            else {
                Task{
                    if let chatRoom = try await APIClient.shared.getChat(chatId:messageData.chatId) {
                        DispatchQueue.main.async {
                            self.allChatRooms.insert(chatRoom, at: 0)
                        }
                    }
                }
            }
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
        allChatRooms.removeAll(where: { $0.id == chatRoom.id})
        DispatchQueue.main.async {
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
    
    
    func getAllChats() async throws {
        if let response = try await APIClient.shared.allChats(page: chatPage, size: chatSize) {
            
            DispatchQueue.main.async{
                let newResponse = response.data
                let existingResponseIDs = Set(self.allChatRooms.suffix(30).map { $0.id })
                let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                
                self.allChatRooms += uniqueNewResponse
                self.lastChatPage = response.lastPage
                self.chatPage += 1
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
        print("chatId: \(chatId), page: \(messagesPage), size: \(messagesSize)")
        if let response = try await APIClient.shared.chatMessages(chatId: chatId, page: messagesPage, size: messagesSize) {
            DispatchQueue.main.async{
                let newResponse = response.data
                let existingResponseIDs = Set(self.messages.prefix(30).map { $0.id })
                let uniqueNewResponse = newResponse.filter { !existingResponseIDs.contains($0.id) }
                
                self.chatRoomId = chatId
                self.messages.insert(contentsOf: uniqueNewResponse, at: 0)
                self.lastMessagesPage = response.lastPage
                self.messagesPage += 1
            }
        }
    }
    
    func setChatAsEntered(chatId: String) async throws {
        if let response = try await APIClient.shared.enterChat(chatId: chatId) {
            DispatchQueue.main.async{
                if let index = self.allChatRooms.firstIndex(where: { $0.id == chatId }) {
                    // Update the chat room's last message and timestamp
                    
                    self.allChatRooms[index].read = true

                }
            }
        }
    }
    
    func setChatAsLeft(chatId: String) async throws {
        if let response = try await APIClient.shared.leaveChat(chatId: chatId) {
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
                    
                    completion(true)
                }
            }
        } catch {
            print("error:", error)
            completion(false)
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
            notificationsList.insert(newNotification, at: 0)
        } else if newNotification.alertBodyPostHasStarted != nil {
            notificationsList.insert(newNotification, at: 0)
        } else if newNotification.alertBodyFriendRequestAccepted != nil {
            notificationsList.removeAll { $0.alertBodyFriendRequestAccepted?.user.id == newNotification.alertBodyFriendRequestAccepted?.user.id }
            notificationsList.insert(newNotification, at: 0)
        }
    }
    
    func notificationCheck(notification: Components.Schemas.NotificationDto) {
        //        let range = min(count + 10, notificationsList.count)
        
        // Remove the notification with the same ID from the first 'range' elements
        notificationsList.removeAll(where: {$0.id == notification.id})
        
        DispatchQueue.main.async {
            print("triggered nottt")
            self.notificationsList.insert(notification, at: 0)
        }
    }
    
    func printNotIds() {
        let array = notificationsList.map { not in
            return not.id
        }
        
        print(array)
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
