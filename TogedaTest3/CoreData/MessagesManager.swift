////
////  MessagesManager.swift
////  TogedaTest3
////
////  Created by Borislav Lorinkov on 22.02.25.
////
//
//import Foundation
//import CoreData
//import Combine
//
//class MessagesManager: ObservableObject {
//    static let shared = MessagesManager()
//    private let context = PersistenceController.shared.context
//
//    @Published var messages: [CDChatMessage] = []
//
//    init() {
//        loadMessages()
//    }
//
//    // Load messages from Core Data
//    func loadMessages() {
//        let fetchRequest: NSFetchRequest<CDChatMessage> = CDChatMessage.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
//        
//        do {
//            self.messages = try context.fetch(fetchRequest)
//        } catch {
//            print("Failed to load messages: \(error)")
//        }
//    }
//    
//    // MARK: - Save New Message to Core Data
//    func saveMessage(chatID: String, senderID: String, text: String, status: String) -> CDChatMessage {
//        let newMessage = CDChatMessage(context: context)
//        newMessage.id = UUID()
//        newMessage.chatID = chatID
//        newMessage.senderID = senderID
//        newMessage.text = text
//        newMessage.timestamp = Date()
//        newMessage.status = status
//        newMessage.isRead = false
//
//        do {
//            try context.save()
//            loadMessages() // Refresh UI
//        } catch {
//            print("Error saving message: \(error)")
//        }
//        
//        return newMessage
//    }
//
//    
//    // MARK: - Update Message Status
//    func updateMessageStatus(messageID: UUID, status: String) {
//        let fetchRequest: NSFetchRequest<CDChatMessage> = CDChatMessage.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", messageID as CVarArg)
//
//        do {
//            let messages = try context.fetch(fetchRequest)
//            if let message = messages.first {
//                message.status = status
//                try context.save()
//                loadMessages()
//            }
//        } catch {
//            print("Failed to update message status: \(error)")
//        }
//    }
//    
//    // MARK: - Delete Old Messages (After 6 Months)
//    func deleteOldMessages() {
//        let fetchRequest: NSFetchRequest<CDChatMessage> = CDChatMessage.fetchRequest()
//        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
//        fetchRequest.predicate = NSPredicate(format: "timestamp < %@", sixMonthsAgo as NSDate)
//
//        do {
//            let oldMessages = try context.fetch(fetchRequest)
//            for message in oldMessages {
//                context.delete(message)
//            }
//            try context.save()
//            loadMessages()
//        } catch {
//            print("Failed to delete old messages: \(error)")
//        }
//    }
//    
//    // MARK: - Retry Failed Messages
//    func retryFailedMessages(chatID: String) {
//        let fetchRequest: NSFetchRequest<CDChatMessage> = CDChatMessage.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "chatID == %@ AND status == %@", chatID, "failed")
//
//        do {
//            let failedMessages = try context.fetch(fetchRequest)
//            for message in failedMessages {
//                message.status = "sending"
//                WebSocketManager.shared.attemptToSendMessage(message) // Send again
//            }
//            try context.save()
//            loadMessages()
//        } catch {
//            print("Failed to retry failed messages: \(error)")
//        }
//    }
//    
//}
