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
    var currentUserId: String
    let size: ImageSize = .xxSmall
    var chatRoom: Components.Schemas.ChatRoomDto
    
    @ObservedObject var vm: ChatViewModel
    
    private var shouldShowChatPartnerImage: Bool {
        guard let next = nextMessage else { return true }
        if nextMessage == nil && !isMessageFromCurrentUser { return true }
        if let date = Calendar.current.dateComponents([.minute], from: message.createdAt, to: next.createdAt).minute, date > 30 {
            return true
        }
        return next.sender.id != message.sender.id
    }
    
    var isMessageFromCurrentUser: Bool {
        message.sender.id == currentUserId
    }
    
    var body: some View {
        HStack{
            if isMessageFromCurrentUser {
                Spacer()
                
                switch message.contentType {
                case .CLUB:
                    MessageClubPreview(clubID: message.content)
                        .padding(.horizontal)
                case .IMAGE:
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
                                .frame(maxWidth: UIScreen.main.bounds.width / 1.5, maxHeight: 400)
                                .cornerRadius(10)
                                .padding(.trailing)
                        }
                    }
                case .NORMAL:
                    Text(LocalizedStringKey(message.content))
                        .textSelection(.enabled)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
                        .padding(.horizontal)
                case .POST:
                    MessagePostPreview(postID: message.content)
                        .padding(.horizontal)
                }
            }
            else {
                HStack(alignment: .bottom, spacing: 8){
                    if shouldShowChatPartnerImage{
                        KFImage(URL(string: message.sender.profilePhotos[0]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                    }
                    
                    switch message.contentType {
                    case .CLUB:
                        VStack(alignment: .leading){
                            if chatRoom._type != .FRIENDS && shouldShowChatPartnerImage {
                                Text("\(message.sender.firstName)")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                            }
                            MessageClubPreview(clubID: message.content)
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                            
                        }
                    case .IMAGE:
                        VStack(alignment: .leading) {
                            if chatRoom._type != .FRIENDS && shouldShowChatPartnerImage {
                                Text("\(message.sender.firstName)")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                            }
                            Button{
                                vm.selectedImage = message.content
                                vm.isImageView = true
                            } label: {
                                KFImage(URL(string: message.content))
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .frame(maxWidth: UIScreen.main.bounds.width / 1.5, maxHeight: 400)
                                    .cornerRadius(10)
                                    .padding(.trailing)
                                    .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                            }
                            
                        }
                        
                    case .NORMAL:
                        VStack(alignment: .leading) {
                            if chatRoom._type != .FRIENDS && shouldShowChatPartnerImage {
                                Text("\(message.sender.firstName)")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                            }
                            Text(LocalizedStringKey(message.content))
                                .textSelection(.enabled)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .foregroundColor(Color("blackAndWhite"))
                                .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                                .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                        }
                    case .POST:
                        VStack(alignment: .leading) {
                            if chatRoom._type != .FRIENDS && shouldShowChatPartnerImage {
                                Text("\(message.sender.firstName)")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                            }
                            MessagePostPreview(postID: message.content)
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                        }
                        
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
        
    }
    
    
}





#Preview {
    ChatMessageCell(message: mockReceivedMessage, currentUserId: "", chatRoom: mockChatRoom, vm: ChatViewModel())
}
