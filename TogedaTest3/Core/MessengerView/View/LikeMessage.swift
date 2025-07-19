//
//  LikeMessage.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 20.01.25.
//

import SwiftUI
import Kingfisher

struct LikeMessage<Content: View>: View {
    let message: Components.Schemas.ReceivedChatMessageDto
    var likeFunc: () -> ()
    var delFunc: () -> ()
    var replyFunc: () -> ()
    var canUnsent: Bool
    var isMessageFromCurrentUser: Bool
    var edit: () -> ()
    var showLikes: () -> ()
    var content: () -> Content
    @State private var offsetX: CGFloat = 0
    @State private var showReplyIcon: Bool = false
    @State private var isDragging = false
    
    var body: some View {
        VStack(alignment: isMessageFromCurrentUser ? .trailing : .leading, spacing: 0){
            if let reply = message.replyTo {
                Text(isMessageFromCurrentUser ? "You replied to \(reply.sender.firstName)" : "\(message.sender.firstName) replied to \(reply.sender.firstName)")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding(.vertical, 10)
                
                VStack{
                    if let isUnsent = reply.isUnsent, isUnsent {
                        Text("Unsent Message")
                            .textSelection(.enabled)
                            .font(.subheadline)
                            .padding(10)
                            .foregroundColor(.gray)
                            .overlay(
                                Capsule()
                                    .stroke(Color.gray, lineWidth: 1)
                                    .opacity(0.5)
                            )
                    } else {
                        switch reply.contentType{
                        case .NORMAL:
                            Text(reply.content)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .foregroundColor(Color("blackAndWhite"))
                                .clipShape(ChatBubble(isFromCurrentUser: false, shouldRoundAllCorners: true))
                                .lineLimit(3)
                        case .CLUB:
                            MessageClubPreview(clubID: reply.content)
                                .scaleEffect(0.6)
                                .frame(width: 180 * 0.6, height: 300 * 0.6)

                        case .IMAGE:
                            KFImage(URL(string: reply.content))
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .frame(width: 90, height: 150)
                                .cornerRadius(10)
                        case .POST:
                            MessagePostPreview(postID: reply.content)
                                .scaleEffect(0.6)
                                .frame(width: 180 * 0.6, height: 300 * 0.6)

                        }
                    }
                }
                .offset(y: 5)
                
            }
            
            ZStack(alignment: isMessageFromCurrentUser ? .trailing : .leading) {
                if showReplyIcon {
                    HStack(){
                        if isMessageFromCurrentUser {
                            Image(systemName: "arrowshape.turn.up.left.fill")
                                .foregroundColor(.gray)
                                .transition(.scale)
                        } else {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .foregroundColor(.gray)
                                .transition(.scale)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                }

                ZStack(alignment: .bottomLeading){
                    content()
                        .offset(x: offsetX)
                        .highPriorityGesture(
                            isMessageFromCurrentUser ?
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.width < 0 && value.translation.width > -80 { // Only allow dragging left
                                        offsetX = value.translation.width
                                        isDragging = true
                                        if value.translation.width < -50 {
                                            showReplyIcon = true
                                        }
                                    }
                                }
                                .onEnded { value in
                                    if offsetX < -50 { // Threshold to trigger reply
                                        print("reply")
                                        replyFunc()
                                        UIImpactFeedbackGenerator(style: .heavy)
                                            .impactOccurred()
                                    }
                                    isDragging = false
                                    withAnimation(.spring()) { // Animate back to original position
                                        offsetX = 0
                                        showReplyIcon = false
                                    }
                                }
                            :
                                DragGesture()
                                .onChanged { value in
                                    if value.translation.width > 0 && value.translation.width < 80 { // Only allow dragging left
                                        offsetX = value.translation.width
                                        if value.translation.width > 50 {
                                            showReplyIcon = true
                                        }
                                    }
                                }
                                .onEnded { value in
                                    if offsetX > 50 { // Threshold to trigger reply
                                        print("reply")
                                        replyFunc()
                                        UIImpactFeedbackGenerator(style: .heavy)
                                            .impactOccurred()
                                    }
                                    withAnimation(.spring()) { // Animate back to original position
                                        offsetX = 0
                                        showReplyIcon = false
                                    }
                                }
                        )
                        .animation(.easeOut(duration: 0.2), value: offsetX)
                        .onTapGesture(count: 2) {
                            likeFunc()
                            UIImpactFeedbackGenerator(style: .heavy)
                                .impactOccurred()
                        }
                        .contextMenu{
                            Button {
                                likeFunc()
                                UIImpactFeedbackGenerator(style: .heavy)
                                    .impactOccurred()
                            } label: {
                                Label("Like", systemImage: "heart.fill")
                            }
                            
                            Button {
                                replyFunc()
                                UIImpactFeedbackGenerator(style: .heavy)
                                    .impactOccurred()
                            } label: {
                                Label("Reply", systemImage: "arrowshape.turn.up.left.fill")
                            }
                            
                            if message.contentType == .NORMAL {
                                Button {
                                    UIPasteboard.general.string = message.content
                                    UIImpactFeedbackGenerator(style: .heavy)
                                        .impactOccurred()
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc.fill")
                                }
                                
                                if isMessageFromCurrentUser && isEditable(createdAt: message.createdAt) {
                                    Button {
                                        edit()
                                    } label: {
                                        Label("Edit", systemImage: "square.and.pencil")
                                    }
                                }
                            }
                            
                            if canUnsent {
                                Button {
                                    delFunc()
                                    UIImpactFeedbackGenerator(style: .heavy)
                                        .impactOccurred()
                                } label: {
                                    Label("Unsent", systemImage: "trash")
                                }
                            }
                            
                            
                        }
                    
                    if let likes = message.likeCount, likes > 0 {
                        Button{
                            showLikes()
                        } label:{
                            HStack(spacing: 5) {
                                if likes > 1 {
                                    Text("\(formatBigNumbers(Int(likes)))")
                                        .fontWeight(.heavy)
                                }
                                Text("❤️")
                                
                            }
                            .font(.custom("", size: 10))
                            .padding(5) // Add padding for spacing inside the capsule
                            .background(
                                Capsule()
                                    .fill(Color.secondaryBackground) // Gray background
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.base, lineWidth: 2) // Gray stroke
                            )
                            .padding(.leading, 10)
                            .offset(y: 15)
                        }
                    }
                    
                }
                .padding(.bottom, message.likeCount ?? 0 > 0 ? 16 : 0)
            }
        }
    }
    
    // Function to check if the message was sent within the last 5 minutes
    func isEditable(createdAt: Date) -> Bool {
        let fiveMinutesAgo = Calendar.current.date(byAdding: .minute, value: -5, to: Date())!
        return createdAt > fiveMinutesAgo
    }
}

#Preview {
    LikeMessage(message: mockReceivedMessage, likeFunc: {}, delFunc: {}, replyFunc: {}, canUnsent: true, isMessageFromCurrentUser: true, edit: {}, showLikes: {}, content: {Rectangle()
        .foregroundStyle(.green)})
}
