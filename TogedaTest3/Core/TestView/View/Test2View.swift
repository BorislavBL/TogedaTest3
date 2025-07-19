//
//  Test2View.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 3.11.23.
//

import SwiftUI
import Kingfisher

struct Test2View: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var draftManager = DraftManager.shared
    
    @State private var messageText: String = ""
    var chatID: String
    
    var body: some View {
        VStack {
            TextEditor(text: $messageText)
                .frame(height: 150)
                .padding()
                .onAppear {
                    if let draft = draftManager.getDraft(chatId: chatID) {
                        messageText = draft
                    }
                }
                .onChange(of: messageText) { newText in
                    draftManager.saveDraft(chatId: chatID, text: newText)
                }

            Button("Send Message") {
                sendMessage()
            }
            .padding()
        }
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Simulate sending a message (Replace with your actual send logic)
        print("Message Sent: \(messageText)")

        // Delete the draft after sending
        draftManager.deleteDraft(chatId: chatID)

        // Clear the input field
        messageText = ""
    }
}

#Preview {
    Test2View(chatID: "dd")
        .environmentObject(LocationManager())
        .environmentObject(PostsViewModel())
        .environmentObject(ClubsViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(NavigationManager())
}

