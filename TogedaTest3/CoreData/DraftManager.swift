//
//  DraftManager.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.02.25.
//

import Foundation
import CoreData
import Combine

class DraftManager: ObservableObject {
    static let shared = DraftManager()
    private let context = PersistenceController.shared.context


    @Published var drafts: [CDChatTextDraft] = []
    
    // Debouncing helper
    private var draftSubject = PassthroughSubject<(String, String), Never>()
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchDrafts()
        
        // Debounce save operations to avoid excessive writes
        draftSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] chatId, text in
                self?.performSaveDraft(chatId: chatId, text: text)
            }
            .store(in: &cancellables)
    }

    // Fetch all drafts
    func fetchDrafts() {
        let fetchRequest: NSFetchRequest<CDChatTextDraft> = CDChatTextDraft.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isDraft == YES")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        do {
            drafts = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch drafts: \(error)")
        }
    }


    func saveDraft(chatId: String, text: String) {
        draftSubject.send((chatId, text))
    }
    
    private func performSaveDraft(chatId: String, text: String) {
        var _text = trimAndLimitWhitespace(text)
        if !_text.isEmpty {
            let fetchRequest: NSFetchRequest<CDChatTextDraft> = CDChatTextDraft.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "chatId == %@ AND isDraft == YES", chatId)
            
            do {
                let existingDrafts = try context.fetch(fetchRequest)
                let draft: CDChatTextDraft
                if let existingDraft = existingDrafts.first {
                    draft = existingDraft
                    draft.text = text
                    draft.timestamp = Date()
                    if let index = drafts.firstIndex(where: { $0.id == draft.id }) {
                        drafts[index] = draft
                    }
                } else {
                    draft = CDChatTextDraft(context: context)
                    draft.id = UUID()
                    draft.chatId = chatId
                    draft.text = text
                    draft.timestamp = Date()
                    draft.isDraft = true
                    drafts.append(draft)
                }
                try context.save()
                //            fetchDrafts()
                
            } catch {
                print("Failed to save draft: \(error)")
            }
        }
    }
    
    
//    // Save or update a draft
//    func saveDraft(chatId: String, text: String) {
//        let fetchRequest: NSFetchRequest<CDChatTextDraft> = CDChatTextDraft.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "chatId == %@ AND isDraft == YES", chatId)
//
//        do {
//            let existingDrafts = try context.fetch(fetchRequest)
//
//            if let existingDraft = existingDrafts.first {
//                existingDraft.text = text
//                existingDraft.timestamp = Date()
//            } else {
//                let newDraft = CDChatTextDraft(context: context)
//                newDraft.id = UUID()
//                newDraft.chatId = chatId
//                newDraft.text = text
//                newDraft.timestamp = Date()
//                newDraft.isDraft = true
//            }
//
//            try context.save()
//            fetchDrafts()
//        } catch {
//            print("Failed to save draft: \(error)")
//        }
//    }

    // Load a draft for a specific chat
    func getDraft(chatId: String) -> String? {
        let draft = drafts.first { $0.chatId == chatId }
        return draft?.text
    }

    // Delete draft when message is sent
    func deleteDraft(chatId: String) {
        let fetchRequest: NSFetchRequest<CDChatTextDraft> = CDChatTextDraft.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chatId == %@ AND isDraft == YES", chatId)

        do {
            let draftsToDelete = try context.fetch(fetchRequest)
            for draft in draftsToDelete {
                context.delete(draft)
            }
            try context.save()
            fetchDrafts()
        } catch {
            print("Failed to delete draft: \(error)")
        }
    }
    
    func cleanOldDrafts() {
        let fetchRequest: NSFetchRequest<CDChatTextDraft> = CDChatTextDraft.fetchRequest()
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        fetchRequest.predicate = NSPredicate(format: "isDraft == YES AND timestamp < %@", oneMonthAgo as NSDate)
        
        do {
            let oldDrafts = try context.fetch(fetchRequest)
            for draft in oldDrafts {
                context.delete(draft)
                if let index = drafts.firstIndex(where: { $0.id == draft.id }) {
                    drafts.remove(at: index)
                }
            }
            try context.save()
        } catch {
            print("Failed to clean old drafts: \(error)")
        }
    }
    
}
