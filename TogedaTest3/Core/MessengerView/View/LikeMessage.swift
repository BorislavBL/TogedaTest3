//
//  LikeMessage.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 20.01.25.
//

import SwiftUI

struct LikeMessage<Content: View>: View {
    let message: Components.Schemas.ReceivedChatMessageDto
    var likeFunc: () -> ()
    var delFunc: () -> ()
    var canUnsent: Bool
    var showLikes: () -> ()
    var content: () -> Content
    
    var body: some View {
        ZStack(alignment: .bottomLeading){
            content()
                .onTapGesture(count: 2) {
                    likeFunc()
                    UIImpactFeedbackGenerator(style: .heavy)
                        .impactOccurred()
                }
                .contextMenu{
                    if message.contentType == .NORMAL {
                        Button {
                            UIPasteboard.general.string = message.content
                            UIImpactFeedbackGenerator(style: .heavy)
                                .impactOccurred()
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc.fill")
                        }
                    }
                    
                    Button {
                        likeFunc()
                        UIImpactFeedbackGenerator(style: .heavy)
                            .impactOccurred()
                    } label: {
                        Label("Like", systemImage: "heart.fill")
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

#Preview {
    LikeMessage(message: mockReceivedMessage, likeFunc: {}, delFunc: {}, canUnsent: true, showLikes: {}, content: {Rectangle()
        .foregroundStyle(.green)})
}
