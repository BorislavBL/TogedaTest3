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
            
            ScrollView{
                ScrollViewReader { proxy in
                    LazyVStack{
                        ForEach(viewModel.messages.indices, id: \.self) { index in
                            VStack{
                                if index == 0 {
                                    Text("\(formatDateAndTime(date: viewModel.messages[index].timestamp))")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                }
                                else if index > 0, let date = Calendar.current.dateComponents([.minute], from: viewModel.messages[index - 1].timestamp, to: viewModel.messages[index].timestamp).minute, date > 30 {
                                    Text("\(formatDateAndTime(date: viewModel.messages[index].timestamp))")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                }
                                
                                ChatMessageCell(message: viewModel.messages[index],
                                                nextMessage: viewModel.nextMessage(forIndex: index))
                            }
                            .id(viewModel.messages[index].id)
                            
                        }
                        
                        if ((viewModel.messages.last?.isFromCurrentUser) == true) {
                            if ((viewModel.messages.last?.read) != nil) {
                                Text("Read")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                                    .frame(maxWidth:.infinity, alignment: .trailing)
                                    .padding(.horizontal)
                            } else {
                                Text("Sending")
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                                    .frame(maxWidth:.infinity, alignment: .trailing)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    .onAppear(){
                        withAnimation(.spring()) {
                            proxy.scrollTo(viewModel.messages.count - 1)
                        }
                    }
                    .onChange(of: viewModel.messages) { oldValue, newValue in
                        //                    guard  let lastMessage = newValue.last else { return }
                        //
                        //                    withAnimation(.spring()) {
                        //                        proxy.scrollTo(lastMessage.id)
                        //                    }
                        withAnimation(.spring()) {
                            proxy.scrollTo(viewModel.messages.count - 1)
                        }
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
        .resignKeyboardOnDragGesture()
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel(), user: MiniUser.MOCK_MINIUSERS[0])
        .environmentObject(PostsViewModel())
}
