//
//  ChatViewModel.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.23.
//

import Foundation
import PhotosUI
import SwiftUI
import Combine

enum ChatState {
    case editing
    case reply
    case normal
}

class ChatViewModel: ObservableObject {
    @Published var showChat = false
    @Published var selectedUser: Components.Schemas.MiniUser?
    @Published var messages: [Components.Schemas.ReceivedChatMessageDto] = []
    @Published var lastPage: Bool = true
    @Published var page: Int32 = 0
    @Published var size: Int32 = 30
    @Published var isLoading: LoadingCases = .noResults
    
    @Published var showLikes: Bool = false
    @Published var likesMessageId: String?
    @Published var likesMembers: [Components.Schemas.MiniUser] = []
    @Published var lastPageUsers: Bool = true
    @Published var pageMembers: Int32 = 0
    @Published var sizeMembers: Int32 = 30
    @Published var isLoadingMembers: Bool = false

    
    @Published var messageImage: UIImage?
    
    @Published var selectedImage: String?
    @Published var isImageView: Bool = false
    @Published var isSendingImage: Bool = false
    @Published var openPhotoPicker: Bool = false
    
    @Published var searchText: String = ""
    @Published var isSearching: Bool = false
    @Published var chatrooms: [Components.Schemas.ChatRoomDto] = []
    @Published var chatroomsPageSize: Int32 = 30
    @Published var chatroomsPage: Int32 = 0
    @Published var chatroomsLastPage: Bool = true
    
    @Published var isReplying: Bool = false
    
    @Published var isEditing: Bool = false {
        didSet{
            if !isEditing {
                editMessage = nil
//                messageText = ""
            }
        }
    }
    
    @Published var chatState: ChatState = .normal
    
    @Published var editMessage: Components.Schemas.ReceivedChatMessageDto?
    @Published var messageText = ""
    @Published var isChatActive: Bool = false
    
    @Published var replyToMessage: Components.Schemas.ReceivedChatMessageDto?
    @Published var replyImage: String?

    @Published var recPadding: CGFloat = 60

    
    var cancellable: AnyCancellable?
    
    func startSearch() {
        cancellable = $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if !value.isEmpty {
                    print("Searching...")
                    self.toDefault()
                    Task{
                       try await self.searchChatrooms()
                    }
                    
                } else {
                    print("Not Searching...")
                    self.toDefault()
                }
            })
    }
    
    func stopSearch() {
        cancellable = nil
        toDefault()
    }
    
    func toDefault() {
        chatrooms = []
        chatroomsPage = 0
        chatroomsLastPage = true
    }
    
    func searchChatrooms() async throws {
        if let response = try await APIClient.shared.searchChatRoom(searchText: searchText, page: page, size: size){
            DispatchQueue.main.async {
                self.chatrooms += response.data
                self.page += 1
                self.chatroomsLastPage = response.lastPage
                self.isLoading = .loaded
            }

        }
    }
    
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
                
                DispatchQueue.main.async {
                    self.messageImage = uiImage
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    
    func resizeImage(image: UIImage, targetHeight: CGFloat) -> UIImage? {
        let size = image.size
        
        // Return the original image if its height is less than or equal to the target height
        guard size.height > targetHeight else {
            return image
        }
        
        let widthRatio = targetHeight / size.height
        let newSize = CGSize(width: size.width * widthRatio, height: targetHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0) // Ensure correct scaling factor
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func uploadImageAsync(uiImage: UIImage) async -> String? {
        let bucketName = bucketName.user.rawValue
        let UUID = NSUUID().uuidString
                
        guard let resizedImage = resizeImage(image: uiImage, targetHeight: CGFloat(CROPPING_HEIGHT)) else {
            print("Image resizing failed.")
            return nil
        }
        
        guard let jpeg = resizedImage.jpegData(compressionQuality: 0.9) else {
                    print("Image compression failed.")
                    return nil
                }
        
        do {
            if let response = try await APIClient.shared.generatePresignedPutUrl(bucketName: bucketName, keyName: UUID) {
                try await ImageService().uploadImage(imageData: jpeg, urlString: response)
                let imageUrl = "https://\(bucketName).s3.eu-central-1.amazonaws.com/\(UUID).jpeg"
                
                return imageUrl
            } else {
                return nil
            }
            
        } catch {
            print("Upload failed with error: \(error)")
            
            return nil
        }
    }
    
    func resetMembers() {
        self.likesMessageId = nil
        self.likesMembers = []
        self.pageMembers = 0
        self.lastPageUsers = true
        self.isLoading = .noResults
    }
    
    func getMessageLikesMembers() async throws{
        if let id = likesMessageId {
            if let response = try await APIClient.shared.likeMembers(messageId: id, pageNumber: pageMembers, pageSize: sizeMembers) {
                DispatchQueue.main.async{
                    self.likesMembers += response.data
                    self.pageMembers += 1
                    self.lastPageUsers = response.lastPage
                }
            }
        }
    }
    
    
}

