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
    @Binding var isReplying: Bool
    var content: () -> Content

    @State private var offsetX: CGFloat = 0
    @State private var showReplyIcon: Bool = false
    @State private var isDragging = false
    
    @State private var dragLock: Axis? = nil
    
    var body: some View {
        VStack(alignment: isMessageFromCurrentUser ? .trailing : .leading, spacing: 0){
            if let reply = message.replyTo {
                if isMessageFromCurrentUser && reply.sender.id == message.sender.id {
                    Text("You replied to yourself")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .padding(.vertical, 10)
                } else {
                    Text(isMessageFromCurrentUser ? "You replied to \(reply.sender.firstName)" : "\(message.sender.firstName) replied to \(reply.sender.firstName)")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .padding(.vertical, 10)
                }
                
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
                                .background(Color("chat-bubble").opacity(0.4))
                                .foregroundColor(Color("blackAndWhite").opacity(0.7))
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
                        .simultaneousGesture(       // ⬅️ use simultaneous, not highPriority
                            DragGesture(minimumDistance: 12, coordinateSpace: .local)
                                .onChanged { value in
                                    let dx = value.translation.width
                                    let dy = value.translation.height
                                    
                                    // decide once which way the user is going
                                    if dragLock == nil {
                                        dragLock = abs(dx) > abs(dy) ? .horizontal : .vertical
                                    }
                                    
                                    // only handle if horizontal, otherwise let ScrollView scroll
                                    guard dragLock == .horizontal else { return }
                                    
                                    isReplying = true
                                    
                                    if isMessageFromCurrentUser {
                                        // allow only left swipe
                                        let clamped = max(-80, min(0, dx))
                                        offsetX = clamped
                                        showReplyIcon = clamped <= -50
                                    } else {
                                        // allow only right swipe
                                        let clamped = min(80, max(0, dx))
                                        offsetX = clamped
                                        showReplyIcon = clamped >= 50
                                    }
                                }
                                .onEnded { value in
                                    defer {
                                        withAnimation(.spring()) {
                                            offsetX = 0
                                            showReplyIcon = false
                                        }
                                        dragLock = nil
                                    }
                                    
                                    isReplying = false
                                    
                                    guard dragLock == .horizontal else { return }
                                    
                                    if (isMessageFromCurrentUser && value.translation.width <= -50) ||
                                        (!isMessageFromCurrentUser && value.translation.width >= 50) {
                                        replyFunc()
                                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
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
    LikeMessage(message: mockReceivedMessage, likeFunc: {}, delFunc: {}, replyFunc: {}, canUnsent: true, isMessageFromCurrentUser: true, edit: {}, showLikes: {}, isReplying: .constant(false), content: {Rectangle()
        .foregroundStyle(.green)})
}
