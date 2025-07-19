//
//  Message.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 10.11.23.
//
//
//import SwiftUI
//
//enum MessageSendType {
//    case text(String)
//    case image(UIImage)
//    case link(String)
//    case post(String)
//}
//
struct ChatMessages: Codable {
    let id: String?
    let senderId: String
    let chatId: String
    let content: String
    let contentType: String
    var replyToMessageId: String?
}

//enum ContentType {
//    case text(String)
//    case image(String)
//    case link(String)
//    case post(String)
//}
//
//struct Message: Identifiable, Codable, Hashable {
//    var messageId: String?
//    let fromId: String
//    let toId: String
//    let text: String
//    let timestamp: Date
//    var user: MiniUser?
//    var read: Bool
//    var imageUrl: String?
//    var post: String?
//    
//    var id: String {
//        return messageId ?? NSUUID().uuidString
//    }
//    
//    var chatPartnerId: String {
//        return fromId == UserDefaults.standard.string(forKey: "userId") ? toId : fromId
//    }
//    
//    var isFromCurrentUser: Bool {
//        return fromId == UserDefaults.standard.string(forKey: "userId")
//    }
//    
//    var isImageMessage: Bool {
//        return imageUrl != nil
//    }
//    
//    var contentType: ContentType {
//        if let imageUrl = imageUrl {
//            return .image(imageUrl)
//        }
//        
//        if text.hasPrefix("http") {
//            return .link(text)
//        }
//        
//        if let postID = post {
//            return .post(postID)
//        }
//        
//        return .text(text)
//    }
//}
//
//extension Message {
//    static var MOCK_MESSAGES: [Message] = [
//        .init(fromId: MiniUser.MOCK_MINIUSERS[0].id, toId: MiniUser.MOCK_MINIUSERS[1].id, text: "hey", timestamp: Date(), user: MiniUser.MOCK_MINIUSERS[1], read: true),
//        .init(fromId: MiniUser.MOCK_MINIUSERS[1].id, toId: MiniUser.MOCK_MINIUSERS[0].id, text: "https://www.youtube.com/watch?v=x237rufnzNA&t=8s djbasiudbhiuasbdiuabshdiub", timestamp: Date(), user: MiniUser.MOCK_MINIUSERS[1], read: true),
//        .init(fromId: MiniUser.MOCK_MINIUSERS[0].id, toId: MiniUser.MOCK_MINIUSERS[1].id, text: "https://www.hackingwithswift.com/articles/237/complete-guide-to-sf-symbols mumbojumbo sajodjoiasjdioa nduashdiuahs https://www.youtube.com/watch?v=x237rufnzNA&t=8s", timestamp: Date(), user: MiniUser.MOCK_MINIUSERS[1], read: true),
//        .init(fromId: MiniUser.MOCK_MINIUSERS[0].id, toId: MiniUser.MOCK_MINIUSERS[1].id, text: "heyyyy", timestamp: Date(), user: MiniUser.MOCK_MINIUSERS[1], read: true, imageUrl: "event_1"),
//        .init(fromId: MiniUser.MOCK_MINIUSERS[0].id, toId: MiniUser.MOCK_MINIUSERS[1].id, text: "", timestamp: Date(), user: MiniUser.MOCK_MINIUSERS[1], read: true, post: ""),
//        .init(fromId: MiniUser.MOCK_MINIUSERS[2].id, toId: MiniUser.MOCK_MINIUSERS[0].id, text: "test test ALERT-BG", timestamp: Date(), user: MiniUser.MOCK_MINIUSERS[2], read: false)
//    ]
//}
//
//
//struct Conversation: Identifiable, Hashable, Codable {
//    var conversationId: String?
//    let lastMessage: Message
//    var firstMessageId: String?
//    
//    var id: String {
//        return conversationId ?? NSUUID().uuidString
//    }
//}
//
//
//extension Conversation {
//    static var MOCK_CONVERSATIONS: [Conversation] = [
//        .init(lastMessage: Message.MOCK_MESSAGES[0]),
//        .init(lastMessage: Message.MOCK_MESSAGES[1])
//    ]
//}
