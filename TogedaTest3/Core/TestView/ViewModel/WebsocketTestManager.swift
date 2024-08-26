////
////  WebSocketManager.swift
////  TogedaTest3
////
////  Created by Borislav Lorinkov on 23.07.24.
////

import SwiftUI
import SwiftStomp

class WebSocketTestManager: ObservableObject, SwiftStompDelegate {
    @Published var swiftStomp: SwiftStomp!
    @Published var currentUserId: String?
    {
        didSet {
            connectToCurrentUser(oldValue: oldValue)
        }
    }
    
    @Published var Init = true
    
    init(){
        if let token = AuthService.shared.getAccessToken() {

                let url = URL(string: "wss://api.togeda.net/ws")! // Ensure using 'wss' or 'ws' schema
                self.swiftStomp = SwiftStomp(host: url, headers: ["Authorization" : "Bearer \(token)"]) //< Create instance
                self.swiftStomp.delegate = self //< Set delegate
                self.swiftStomp.autoReconnect = true //< Auto reconnect on error or cancel
                self.swiftStomp.enableLogging = false
                
                self.swiftStomp.connect()
            
        }

    }
    
}

extension WebSocketTestManager {
    
    func websocketInit(token: String) {
        
    }
    
    func connect() {
        self.swiftStomp.connect() //< Connect
    }
    
    func disconnect() {
        print("Disconnected websocket")
        if !Init {
            swiftStomp.unsubscribe(from: "/user/\(currentUserId)/queue/messages")
            swiftStomp.unsubscribe(from: "/user/\(currentUserId)/queue/notifications")
            
            self.swiftStomp.disconnect()
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
    
    func connectToCurrentUser(oldValue: String?) {
        if self.swiftStomp.connectionStatus == .fullyConnected {
            if let id = self.currentUserId{
                print(id)
                swiftStomp.unsubscribe(from: "/user/\(oldValue ?? id)/queue/messages")
                swiftStomp.unsubscribe(from: "/user/\(oldValue ?? id)/queue/notifications")
                swiftStomp.subscribe(to: "/user/\(id)/queue/messages", mode: .clientIndividual)
                swiftStomp.subscribe(to: "/user/\(id)/queue/notifications", mode: .clientIndividual)
                
                Init = false
            }
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
                    swiftStomp.subscribe(to: "/user/\(id)/queue/notifications", mode: .clientIndividual)
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
//        do {
//            if destination == "/app/chat" {
//                if let message = message as? String, let jsonData = message.data(using: .utf8) {
//                    print("Message:: \(message)")
//                    let decoder = JSONDecoder()
//                    decoder.dateDecodingStrategy = .iso8601
//
//                    let messageData = try decoder.decode(Components.Schemas.ReceivedChatMessageDto.self, from: jsonData)
//
//                    chatRoomCheckWithMessage(messageData: messageData)
//
//                    if let chatRoomId, messageData.chatId == chatRoomId {
//                        DispatchQueue.main.async {
//                            self.messages.append(messageData)
//                        }
//                    }
//
//                    DispatchQueue.main.async {
//                        if let message = message as? String{
//                            self.messagesString.insert(message, at: 0)
//                        }
//                    }
//
//
//                } else {
//                    print("The message can't be converted into a data!")
//                }
//            }
//        } catch {
//            print("Message error:", error)
//        }
        
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
