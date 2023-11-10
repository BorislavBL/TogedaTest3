//
//  Message.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 10.11.23.
//

import SwiftUI

enum MessageSendType {
    case text(String)
    case image(UIImage)
    case link(String)
}

enum ContentType {
    case text(String)
    case image(String)
    case link(String)
}

struct Message: Identifiable, Codable, Hashable {
    var messageId: String?
    let fromId: String
    let toId: String
    let text: String
    let timestamp: Date
    var user: MiniUser?
    var read: Bool
    var imageUrl: String?
    
    var id: String {
        return messageId ?? NSUUID().uuidString
    }
    
//    var chatPartnerId: String {
//        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
//    }
//    
//    var isFromCurrentUser: Bool {
//        return fromId == Auth.auth().currentUser?.uid
//    }
    
    var isImageMessage: Bool {
        return imageUrl != nil
    }
    
    var contentType: ContentType {
        if let imageUrl = imageUrl {
            return .image(imageUrl)
        }
        
        if text.hasPrefix("http") {
            return .link(text)
        }
        
        return .text(text)
    }
}

extension Message {
    static var MOCK_MESSAGES: [Message] = [
        .init(fromId: MiniUser.MOCK_MINIUSERS[0].id, toId: MiniUser.MOCK_MINIUSERS[1].id, text: "hey bbbbbbitch", timestamp: Date(), user: MiniUser.MOCK_MINIUSERS[1], read: true),
        .init(fromId: MiniUser.MOCK_MINIUSERS[2].id, toId: MiniUser.MOCK_MINIUSERS[0].id, text: "hey bbbbbbitch", timestamp: Date(), user: MiniUser.MOCK_MINIUSERS[2], read: false)
    ]
}

struct Conversation: Identifiable, Hashable, Codable {
    var conversationId: String?
    let lastMessage: Message
    var firstMessageId: String?
    
    var id: String {
        return conversationId ?? NSUUID().uuidString
    }
}

extension Conversation {
    static var MOCK_CONVERSATIONS: [Conversation] = [
        .init(lastMessage: Message.MOCK_MESSAGES[0]),
        .init(lastMessage: Message.MOCK_MESSAGES[1])
    ]
}
