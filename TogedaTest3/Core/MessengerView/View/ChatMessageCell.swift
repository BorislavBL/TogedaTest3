//
//  ChatMessageCell.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.11.23.
//

import SwiftUI
import WrappingHStack
import Kingfisher

struct ChatMessageCell: View {
    let message: Components.Schemas.ReceivedChatMessageDto
    var nextMessage: Components.Schemas.ReceivedChatMessageDto?
    var prevMessage: Components.Schemas.ReceivedChatMessageDto?
    
    var currentUserId: String
    let size: ImageSize = .xxSmall
    var chatRoom: Components.Schemas.ChatRoomDto
    var isAdmin: Bool
    
    @ObservedObject var vm: ChatViewModel
    
    private var shouldShowChatPartnerImage: Bool {
        guard let next = nextMessage else { return true }
        if nextMessage == nil && !isMessageFromCurrentUser { return true }
        //        if let date = Calendar.current.dateComponents([.minute], from: message.createdAt, to: next.createdAt).minute, date > 30 {
        //            return true
        //        }
        return next.sender.id != message.sender.id
    }
    
    private var shouldShowName: Bool {
        guard let prev = prevMessage else { return true }
        if prevMessage == nil && !isMessageFromCurrentUser { return true }
        //        if let date = Calendar.current.dateComponents([.minute], from: message.createdAt, to: next.createdAt).minute, date > 30 {
        //            return true
        //        }
        return prev.sender.id != message.sender.id
    }
    
    var isMessageFromCurrentUser: Bool {
        message.sender.id == currentUserId
    }
    
    private var canUnsent: Bool {
        return message.sender.id == currentUserId || isAdmin
    }
    
    var body: some View {
        HStack{
            if isMessageFromCurrentUser {
                Spacer()
                
                if let unsent = message.isUnsent, unsent {
                    Text("Unsent Message")
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                } else {
                    switch message.contentType {
                    case .CLUB:
                        LikeMessage(message: message, likeFunc: likeDislikeMessage, delFunc: unsentMessage, canUnsent: canUnsent, showLikes: showLikes) {
                            MessageClubPreview(clubID: message.content)
                        }
                        .padding(.horizontal)
                    case .IMAGE:
                        LikeMessage(message: message, likeFunc: likeDislikeMessage, delFunc: unsentMessage, canUnsent: canUnsent, showLikes: showLikes) {
                            Button{
                                hideKeyboard()
                                vm.selectedImage = message.content
                                vm.isImageView = true
                            } label: {
                                VStack(alignment: .trailing) {
                                    KFImage(URL(string: message.content))
                                        .resizable()
                                        .scaledToFill()
                                        .clipped()
                                        .frame(width: 180, height: 300)
                                        .cornerRadius(10)
                                    
                                }
                            }
                        }
                        .padding(.trailing)
                    case .NORMAL:
                        LikeMessage(message: message, likeFunc: likeDislikeMessage, delFunc: unsentMessage, canUnsent: canUnsent, showLikes: showLikes) {
                            Text(LocalizedStringKey(message.content))
                                .font(.subheadline)
                                .padding(12)
                            //                        .background(Color.random())
                                .background(Color(.systemBlue))
                                .foregroundColor(.white)
                                .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                            
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
                        .padding(.horizontal)
                    case .POST:
                        LikeMessage(message: message, likeFunc: likeDislikeMessage, delFunc: unsentMessage, canUnsent: canUnsent, showLikes: showLikes) {
                            MessagePostPreview(postID: message.content)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            else {
                HStack(alignment: .bottom, spacing: 8){
                    if shouldShowChatPartnerImage{
                        NavigationLink(value: SelectionPath.profile(message.sender)){
                            KFImage(URL(string: message.sender.profilePhotos[0]))
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.dimension, height: size.dimension)
                                .clipShape(Circle())
                        }
                    }
                    
                    if let unsent = message.isUnsent, unsent {
                        Text("Unsent Message")
                            .textSelection(.enabled)
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .foregroundColor(Color("blackAndWhite"))
                            .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                            .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                            .padding(.leading, shouldShowChatPartnerImage ? 0 : size.dimension + 8)
                    } else {
                        
                        switch message.contentType {
                        case .CLUB:
                            
                            VStack(alignment: .leading){
                                if chatRoom._type != .FRIENDS && shouldShowName {
                                    Text("\(message.sender.firstName)")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .padding(.top)
                                        .padding(.leading, shouldShowChatPartnerImage ? 0 : size.dimension + 8)
                                }
                                LikeMessage(message: message, likeFunc: likeDislikeMessage, delFunc: unsentMessage, canUnsent: canUnsent, showLikes: showLikes) {
                                    
                                    MessageClubPreview(clubID: message.content)
                                }
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : size.dimension + 8)
                                
                            }
                        case .IMAGE:
                            VStack(alignment: .leading) {
                                if chatRoom._type != .FRIENDS && shouldShowName {
                                    Text("\(message.sender.firstName)")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .padding(.top)
                                        .padding(.leading, shouldShowChatPartnerImage ? 0 : size.dimension + 8)
                                    
                                }
                                LikeMessage(message: message, likeFunc: likeDislikeMessage, delFunc: unsentMessage, canUnsent: canUnsent, showLikes: showLikes) {
                                    Button{
                                        vm.selectedImage = message.content
                                        vm.isImageView = true
                                    } label: {
                                        KFImage(URL(string: message.content))
                                            .resizable()
                                            .scaledToFill()
                                            .clipped()
                                            .frame(width: 180, height: 300)
                                            .cornerRadius(10)
                                            .padding(.trailing)
                                        
                                    }
                                }
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : size.dimension + 8)
                                
                            }
                            
                        case .NORMAL:
                            VStack(alignment: .leading) {
                                if chatRoom._type != .FRIENDS && shouldShowName {
                                    Text("\(message.sender.firstName)")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .padding(.top)
                                        .padding(.leading, shouldShowChatPartnerImage ? 0 : size.dimension + 8)
                                    
                                }
                                
                                LikeMessage(message: message, likeFunc: likeDislikeMessage, delFunc: unsentMessage, canUnsent: canUnsent, showLikes: showLikes) {
                                    
                                    Text(LocalizedStringKey(message.content))
                                        .font(.subheadline)
                                        .padding(12)
                                        .background(Color(.systemGray6))
                                        .foregroundColor(Color("blackAndWhite"))
                                        .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                                        .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                                }
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : size.dimension + 8)
                            }
                        case .POST:
                            VStack(alignment: .leading) {
                                if chatRoom._type != .FRIENDS && shouldShowName {
                                    Text("\(message.sender.firstName)")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                        .padding(.top)
                                        .padding(.leading, shouldShowChatPartnerImage ? 0 : size.dimension + 8)
                                    
                                }
                                LikeMessage(message: message, likeFunc: likeDislikeMessage, delFunc: unsentMessage, canUnsent: canUnsent, showLikes: showLikes) {
                                    
                                    MessagePostPreview(postID: message.content)
                                }
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : size.dimension + 8)
                            }
                            
                        }
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
        
    }
    
    func likeDislikeMessage() {
        Task {
            if let _ = try await APIClient.shared.likeDislikeMessage(messageId: message.id) {
                
            }
        }
    }
    
    func unsentMessage() {
        Task {
            if let _ = try await APIClient.shared.unsendMessage(messageId: message.id) {
                
            }
        }
    }
    
    func showLikes() {
        vm.showLikes = true
        vm.likesMessageId = message.id
    }
    
}





#Preview {
    ChatMessageCell(message: mockReceivedMessage, currentUserId: "", chatRoom: mockChatRoom, isAdmin: true, vm: ChatViewModel())
}
