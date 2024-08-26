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
    var prevMessage: Components.Schemas.ReceivedChatMessageDto?
    
    @ObservedObject var vm: ChatViewModel
    
    private var shouldShowChatPartnerImage: Bool {
        if nextMessage == nil && !isMessageFromCurrentUser { return true }
        //        if let prevMessage = prevMessage, let date = Calendar.current.dateComponents([.minute], from: prevMessage.createdAt, to: message.createdAt).minute, date > 30 {
        //            return true
        //        }
        guard let next = nextMessage else { return isMessageFromCurrentUser }
        return next.sender.id == currentUserId
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
                    Text(message.content)
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
                
                //                switch message.contentType {
                //                case .text(let messageText):
                //                    Text(messageText)
                //                        .font(.subheadline)
                //                        .padding(12)
                //                        .background(Color(.systemBlue))
                //                        .foregroundColor(.white)
                //                        .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                //                        .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
                //                        .padding(.horizontal)
                //                case .image(let imageUrl):
                //                    VStack(alignment: .trailing) {
                //                        Image(imageUrl)
                //                            .resizable()
                //                            .scaledToFill()
                //                            .clipped()
                //                            .frame(maxWidth: UIScreen.main.bounds.width / 1.5, maxHeight: 400)
                //                            .cornerRadius(10)
                //                            .padding(.trailing)
                //
                //                        if !message.text.isEmpty{
                //                            Text(message.text)
                //                                .font(.subheadline)
                //                                .padding(12)
                //                                .background(Color(.systemBlue))
                //                                .foregroundColor(.white)
                //                                .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                //                                .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
                //                                .padding(.horizontal)
                //                        }
                //                    }
                //                case .link(let urlString):
                //                    VStack(alignment: .trailing) {
                //                        LinkPreview(urlString: urlString)
                //                            .padding(.vertical, 12)
                //
                //                        textWithLinks(text: message.text)
                //                            .foregroundColor(.white)
                //                            .tint(.white)
                //                            .font(.subheadline)
                //                            .padding(12)
                //                            .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                //                            .background(Color(.systemBlue))
                //                            .foregroundColor(.white)
                //                            .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                //                    }
                //                    .padding(.horizontal, 12)
                //
                //                case .post(let postID):
                ////                    Text("\(postID)")
                //                    MessagePostPreview(postID: postID)
                //                        .padding(.horizontal)
                //                }
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
                            Text(message.content)
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
                    //
                    //                    switch message.contentType {
                    //                    case .text(let messageText):
                    //                        Text(messageText)
                    //                            .font(.subheadline)
                    //                            .padding(12)
                    //                            .background(Color(.systemGray6))
                    //                            .foregroundColor(Color("blackAndWhite"))
                    //                            .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                    //                            .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                    //                            .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                    //                    case .image(let imageUrl):
                    //                        VStack(alignment: .leading) {
                    //                            Image(imageUrl)
                    //                                .resizable()
                    //                                .scaledToFill()
                    //                                .clipped()
                    //                                .frame(maxWidth: UIScreen.main.bounds.width / 1.5, maxHeight: 400)
                    //                                .cornerRadius(10)
                    //                                .padding(.trailing)
                    //                                .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                    //
                    //                            if !message.text.isEmpty{
                    //                                Text(message.text)
                    //                                    .font(.subheadline)
                    //                                    .padding(12)
                    //                                    .background(Color(.systemGray6))
                    //                                    .foregroundColor(Color("blackAndWhite"))
                    //                                    .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                    //                                    .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                    //                                    .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                    //                            }
                    //                        }
                    //                    case .link(let urlString):
                    //                        VStack(alignment: .leading){
                    //                            LinkPreview(urlString: urlString)
                    //                                .padding(.vertical, 12)
                    //
                    //                            textWithLinks(text: message.text)
                    //                                .foregroundColor(Color("blackAndWhite"))
                    //                                .font(.subheadline)
                    //                                .padding(12)
                    //                                .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                    //                                .background(Color(.systemGray6))
                    //
                    //                                .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                    //                                .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                    //                        }
                    //                        .padding(.horizontal, 12)
                    //                    case .post(let postID):
                    ////                        Text("\(postID)")
                    //                        MessagePostPreview(postID: postID)
                    //                            .padding(.horizontal)
                    //                    }
                    //
                    
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
