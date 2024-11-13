//
//  MessageInputView2.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 21.10.24.
//

import SwiftUI
import PhotosUI

struct MessageInputView2: View {
    @Binding var messageText: String
    @Binding var isChatActive: Bool
    @ObservedObject var viewModel: ChatViewModel
    @FocusState var isFocused: Bool
    var proxy: ScrollViewProxy?
    var onSubmit: () -> ()
    @EnvironmentObject var webSocketMangager: WebSocketManager
    
    var body: some View {
        HStack(alignment: .top){
            if let uiImage = viewModel.messageImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: 100, height: 140)
                        .cornerRadius(10)
                    
                    Button(action: {
                        viewModel.messageImage = nil
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .padding(8)
                    })
                    .background(Color(.gray))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .padding(5)
                }
                .padding(8)
                
                Spacer()
            } else {
                if messageText.isEmpty {
                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                        Image(systemName: "photo")
                            .padding(.horizontal, 4)
                            .foregroundColor(.gray)
                    }
                }
                
                TextField("Message..", text: $messageText, axis: .vertical)
                    .focused($isFocused)
                    .padding(.leading, 4)
                    .font(.subheadline)
                    .onChange(of: isFocused) {
                        if isFocused{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
                                withAnimation(.easeIn) {
                                    proxy?.scrollTo(webSocketMangager.messages.last?.id, anchor: .bottom)
                                }
                            }

                        }
                    }
            }
            
            Button {
                onSubmit()
            } label: {
                Text("Send")
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 8)
            
        }
        .padding(12)
        //            .background(Color("SecondaryBackground"))
        .background(Color("blackAndWhite").opacity(0.1))
        .cornerRadius(20)
        .overlay {
            if viewModel.messageImage != nil {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

#Preview {
    ScrollViewReader { proxy in
        MessageInputView2(
            messageText: .constant(""),
            isChatActive: .constant(false),
            viewModel: ChatViewModel(),
            onSubmit: {})
            .environmentObject(WebSocketManager())
    }
}


