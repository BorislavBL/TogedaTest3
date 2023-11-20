//
//  ChatMessageCell.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 18.11.23.
//

import SwiftUI

struct ChatMessageCell: View {
    let message: Message
    var nextMessage: Message?
    let size: ImageSize = .xxSmall
    var message1: AttributedString {
        var result = AttributedString("Learn Swift here")
        result.font = .largeTitle
        result.link = URL(string: "https://www.hackingwithswift.com")
        return result
    }

    
    private var shouldShowChatPartnerImage: Bool {
        if nextMessage == nil && !message.isFromCurrentUser { return true }
        guard let next = nextMessage else { return message.isFromCurrentUser }
        return next.isFromCurrentUser
    }
    
    var body: some View {
        HStack{
            if message.isFromCurrentUser {
                Spacer()
                switch message.contentType {
                case .text(let messageText):
                    Text(messageText)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemBlue))
                        .foregroundColor(.white)
                        .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                        .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .trailing)
                        .padding(.horizontal)
                case .image(let imageUrl):
                    VStack(alignment: .trailing) {
                        Image(imageUrl)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(maxWidth: UIScreen.main.bounds.width / 1.5, maxHeight: 400)
                            .cornerRadius(10)
                            .padding(.trailing)
                        
                        if !message.text.isEmpty{
                            Text(message.text)
                                .font(.subheadline)
                                .padding(12)
                                .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                                .background(Color(.systemBlue))
                                .foregroundColor(.white)
                                .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                                .padding(.horizontal)
                        }
                    }
                case .link(let urlString):
                    VStack(alignment: .trailing) {
                        LinkPreview(urlString: urlString)
                            .padding(.vertical, 12)

                        Text(message.text)
                            .font(.subheadline)
                            .padding(12)
                            .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                            .background(Color(.systemBlue))
                            .foregroundColor(.white)
                            .clipShape(ChatBubble(isFromCurrentUser: true, shouldRoundAllCorners: false))
                    }
                    .padding(.horizontal, 12)
                        
                }
            } else {
                HStack(alignment: .bottom, spacing: 8){
                    if shouldShowChatPartnerImage, let user = message.user {
                        Image(user.profileImageUrl[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.dimension, height: size.dimension)
                            .clipShape(Circle())
                    }
                    
                    switch message.contentType {
                    case .text(let messageText):
                        Text(messageText)
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .foregroundColor(Color("blackAndWhite"))
                            .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                            .frame(maxWidth: UIScreen.main.bounds.width / 1.75, alignment: .leading)
                            .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                    case .image(let imageUrl):
                        VStack(alignment: .leading) {
                            Image(imageUrl)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .frame(maxWidth: UIScreen.main.bounds.width / 1.5, maxHeight: 400)
                                .cornerRadius(10)
                                .padding(.trailing)
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                            
                            if !message.text.isEmpty{
                                Text(message.text)
                                    .font(.subheadline)
                                    .padding(12)
                                    .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .foregroundColor(Color("blackAndWhite"))
                                    .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                                    .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                            }
                        }
                    case .link(let urlString):
                        VStack(alignment: .leading){
                            LinkPreview(urlString: urlString)
                                .padding(.vertical, 12)
                            
                            Text(message.text)
                                .font(.subheadline)
                                .padding(12)
                                .frame(maxWidth: UIScreen.main.bounds.width / 1.5, alignment: .leading)
                                .background(Color(.systemGray6))
                                .foregroundColor(Color("blackAndWhite"))
                                .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: !shouldShowChatPartnerImage))
                                .padding(.leading, shouldShowChatPartnerImage ? 0 : 32)
                        }
                        .padding(.horizontal, 12)
                    }
                    

                }
                .padding(.horizontal)
                Spacer()
            }
        }

    }
}


#Preview {
    ChatMessageCell(message: Message.MOCK_MESSAGES[1])
}
