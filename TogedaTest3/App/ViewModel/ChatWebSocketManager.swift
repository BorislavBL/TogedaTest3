////
////  ChatWebSocketManager.swift
////  TogedaTest3
////
////  Created by Borislav Lorinkov on 23.07.24.
////

import SwiftUI
import SwiftStomp

class ChatWebSocketManager: ObservableObject, SwiftStompDelegate {
    @Published var allChatRooms: [Components.Schemas.ChatRoomDto] = []
    @Published var chatPage: Int32 = 0
    @Published var chatSize: Int32 = 15
    @Published var lastChatPage = true
    @Published var Init = true
    
    @Published var messages: [Components.Schemas.ReceivedChatMessageDto] = []
    @Published var messagesString: [String] = []
    @Published var lastMessagesPage: Bool = true
    @Published var messagesPage: Int32 = 0
    @Published var messagesSize: Int32 = 15
    @Published var chatRoomId: String?
    
    @Published var swiftStomp: SwiftStomp!
    @Published var currentUserId: String? {
        didSet {
            connectToCurrentUser(oldValue: oldValue)
        }
    }
    
    init(){
        let url = URL(string: "wss://api.togeda.net/ws")! // Ensure using 'wss' or 'ws' schema
        
        self.swiftStomp = SwiftStomp(host: url, headers: nil) //< Create instance
        self.swiftStomp.delegate = self //< Set delegate
        self.swiftStomp.autoReconnect = true //< Auto reconnect on error or cancel
        self.swiftStomp.enableLogging = false
        
        self.swiftStomp.connect()
    }
    
}

extension ChatWebSocketManager {
    
    func connect() {
        self.swiftStomp.connect() //< Connect
    }
    
    func disconnect() {
        print("Disconnected websocket")
        if !Init {
            if let id = self.currentUserId{
                swiftStomp.unsubscribe(from: "/user/\(id)/queue/messages")
            }
        }
        
        self.swiftStomp.disconnect()
    }
    
    func connectToCurrentUser(oldValue: String?) {
        if self.swiftStomp.connectionStatus == .fullyConnected {
            if let id = self.currentUserId{
                print(id)
                swiftStomp.unsubscribe(from: "/user/\(oldValue ?? id)/queue/messages")
                swiftStomp.subscribe(to: "/user/\(id)/queue/messages", mode: .clientIndividual)
                Init = false
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
            
            if !Init {
                if let id = self.currentUserId{
                    swiftStomp.subscribe(to: "/user/\(id)/queue/messages", mode: .clientIndividual)
                }
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
            if let message = message as? String, let jsonData = message.data(using: .utf8) {
                print("Message:: \(message)")
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let messageData = try decoder.decode(Components.Schemas.ReceivedChatMessageDto.self, from: jsonData)
                
                chatRoomCheck(messageData: messageData)

                if let chatRoomId, messageData.chatId == chatRoomId {
                    DispatchQueue.main.async {
                        self.messages.append(messageData)
                    }
                }
                
            } else {
                print("The message can't be converted into a data!")
            }
        } catch {
            print("Message error:", error)
        }
        
        if let message = message as? String{
            messagesString.insert(message, at: 0)
        }
        
        if let message = message as? String {
            print("Message with id `\(messageId)` received at destination `\(destination)`:\n\(message)")
            print("\(Date())")
            
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
        
        //        let insertMessage = Components.Schemas.ChatMessage(id: UUID().uuidString, chatId: chatId, senderId: senderId, content: content, contentType: type, createdAt: Date())
        
        //        messages.append(insertMessage)
        
        //        if let index = allChatRooms.firstIndex(where: { $0.id == insertMessage.chatId }) {
        //            // Update the chat room's last message and timestamp
        //            var chatRoom = allChatRooms[index]
        //            chatRoom.latestMessage = insertMessage
        //            chatRoom.latestMessageTimestamp = insertMessage.createdAt
        //
        //            // Remove the chat room from its current position
        //            allChatRooms.remove(at: index)
        //            
        //            // Insert the chat room at the top of the list
        //            allChatRooms.insert(chatRoom, at: 0)
        //        }
        
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

extension ChatWebSocketManager {
    func chatRoomCheck(messageData: Components.Schemas.ReceivedChatMessageDto) {
        if let index = allChatRooms.firstIndex(where: { $0.id == messageData.chatId }) {
            // Update the chat room's last message and timestamp
            var chatRoom = allChatRooms[index]
            chatRoom.latestMessage = messageData
            chatRoom.latestMessageTimestamp = messageData.createdAt
            
            DispatchQueue.main.async {
                // Remove the chat room from its current position
                self.allChatRooms.remove(at: index)
                
                // Insert the chat room at the top of the list
                self.allChatRooms.insert(chatRoom, at: 0)
            }
        } else {
            Task{
                if let chatRoom = try await APIClient.shared.getChat(chatId:messageData.chatId) {
                    DispatchQueue.main.async {
                        self.allChatRooms.insert(chatRoom, at: 0)
                    }
                }
            }
        }
    }
    
    func getAllChats() async throws {
        if let response = try await APIClient.shared.allChats(page: chatPage, size: chatSize) {
            
            DispatchQueue.main.async{
                self.allChatRooms += response.data
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
                self.chatRoomId = chatId
                self.messages += response.data
                self.lastMessagesPage = response.lastPage
                self.messagesPage += 1
            }
        }
    }
}
