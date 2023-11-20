//
//  ChatView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.23.
//

import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var isInitialLoad = false
    @StateObject var viewModel = ChatViewModel()
    @Environment(\.dismiss) private var dismiss
    let user: MiniUser
    var body: some View {
        VStack{
            ScrollViewReader { proxy in
                ScrollView{
                    LazyVStack{
                        ForEach(viewModel.messages.indices, id: \.self) { index in
                            ChatMessageCell(message: viewModel.messages[index],
                                            nextMessage: viewModel.nextMessage(forIndex: index))
                                .id(viewModel.messages[index].id)
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: viewModel.messages) { oldValue, newValue in
                    guard  let lastMessage = newValue.last else { return }
            
                    withAnimation(.spring()) {
                        proxy.scrollTo(lastMessage.id)
                    }
                }
            }
            
            Spacer()
            
            MessageInputView(messageText: $messageText, viewModel: viewModel)
        }
        .navigationTitle(user.fullname)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:Button(action: {dismiss()}) {
            Image(systemName: "chevron.left")
        })
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel(), user: MiniUser.MOCK_MINIUSERS[0])
}
