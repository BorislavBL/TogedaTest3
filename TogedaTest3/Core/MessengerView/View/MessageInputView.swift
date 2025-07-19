//
//  MessageInputView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.23.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct MessageInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    @FocusState var isFocused: Bool
    var onSubmit: () -> ()
//    @EnvironmentObject var webSocketMangager: WebSocketManager
    
    var body: some View {
        VStack(){
            switch viewModel.chatState {
            case .editing:
                HStack(alignment: .center) {
                    Text("Edit Message")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.chatState = .normal
                        viewModel.messageText = ""
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .padding(8)
                    })
                    .background(Color(.systemGray4))
                    .foregroundColor(.blackAndWhite)
                    .clipShape(Circle())
                    .padding(5)
                }
                .padding(.horizontal)
            case .reply:
                if let reply = viewModel.replyToMessage{
                    HStack(alignment: .center) {
                        VStack(alignment: .leading){
                            Text("Replying to \(reply.sender.firstName) \(reply.sender.lastName)")
                                .font(.footnote)
                                .fontWeight(.semibold)
                            
                            switch reply.contentType{
                            case .CLUB:
                                Text("Club: \(reply.content)")
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .foregroundStyle(.gray)
                            case .IMAGE:
                                Text("Image")
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .foregroundStyle(.gray)
                            case .POST:
                                Text("Event: \(reply.content)")
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .foregroundStyle(.gray)
                            case .NORMAL:
                                Text(reply.content)
                                    .font(.footnote)
                                    .lineLimit(3)
                                    .foregroundStyle(.gray)
                            }
                        }
                        Spacer()
                        
                        switch reply.contentType{
                        case .CLUB:
                            if let image = viewModel.replyImage {
                                KFImage(URL(string: image)!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(10)
                            } else {
                                EmptyView()
                            }
                        case .IMAGE:
                            KFImage(URL(string: reply.content)!)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                        case .POST:
                            if let image = viewModel.replyImage {
                                KFImage(URL(string: image)!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(10)
                            } else {
                                EmptyView()
                            }
                        case .NORMAL:
                            EmptyView()
                        }
                        
                        Button(action: {
                            viewModel.chatState = .normal
                            viewModel.replyToMessage = nil
                        }, label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                                .padding(8)
                        })
                        .background(Color(.systemGray4))
                        .foregroundColor(.blackAndWhite)
                        .clipShape(Circle())
                        .padding(5)
                        
                    }
                    .padding(.horizontal)
                }
            case .normal:
                EmptyView()
            }
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
                    if viewModel.messageText.isEmpty, viewModel.chatState != .editing {
//                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                        Button{
                            viewModel.openPhotoPicker = true
                            hideKeyboard()
                            viewModel.recPadding = 60
                        } label: {
                            Image(systemName: "photo")
                                .padding(.horizontal, 4)
                                .foregroundColor(.gray)
                        }
//                        }
                    }
                    

                    
                    TextField("Message..", text: $viewModel.messageText, axis: .vertical)
                        .lineLimit(6)
                        .focused($isFocused)
                        .padding(.leading, 4)
                        .font(.subheadline)
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
            .sync($viewModel.isChatActive, with: _isFocused)
        }
    }
}

#Preview {
    ScrollViewReader { proxy in
        MessageInputView(
            viewModel: ChatViewModel(),
            onSubmit: {})
            .environmentObject(WebSocketManager())
    }
}

