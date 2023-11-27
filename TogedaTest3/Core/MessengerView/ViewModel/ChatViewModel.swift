//
//  ChatViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.23.
//

import Foundation
import PhotosUI
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var showChat = false
    @Published var selectedUser: MiniUser?
    @Published var messages: [Message] = Message.MOCK_MESSAGES
    @Published var messageImage: Image?
    @Published var selectedItem: PhotosPickerItem? = nil {
        didSet {
            setImage(from: selectedItem)
        }
    }
    
    
    func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        
        Task {
            
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                
                messageImage = Image(uiImage: uiImage)
                
            } catch {
                print(error)
            }
        }
    }
    
    func nextMessage(forIndex index: Int) -> Message? {
        return index != messages.count - 1 ? messages[index + 1] : nil
    }
}

