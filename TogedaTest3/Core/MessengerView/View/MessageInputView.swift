//
//  MessageInputView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 15.11.23.
//

import SwiftUI
import PhotosUI

struct MessageInputView: View {
    @Binding var messageText: String
    @ObservedObject var viewModel: ChatViewModel
    var onSubmit: () -> ()
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
                        PhotosPicker(selection: $viewModel.selectedItem) {
                            Image(systemName: "photo")
                                .padding(.horizontal, 4)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    TextField("Message..", text: $messageText, axis: .vertical)
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
            .background(Color("SecondaryBackground"))
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
    MessageInputView(messageText: .constant(""), viewModel: ChatViewModel(), onSubmit: {})
}
