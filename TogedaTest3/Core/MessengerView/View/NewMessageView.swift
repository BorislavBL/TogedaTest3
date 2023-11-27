//
//  NewMessageView.swift
//  TogedaTest3
//
//  Created by Borislav Lorinkov on 24.11.23.
//

import SwiftUI

struct NewMessageView: View {
    @Environment(\.dismiss) var dismiss
    @State var searchText: String = ""
    @ObservedObject var chatVM: ChatViewModel
//    @Binding var selectedUser: MiniUser?
    let size: ImageSize = .small

    
    var body: some View {
        NavigationStack {
            ScrollView {
                TextField("To: ", text: $searchText)
                    .frame(height: 44)
                    .padding(.leading)
                    .background(Color(.systemGroupedBackground))
                
                Text("CONTACTS")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                LazyVStack {
                    ForEach(MiniUser.MOCK_MINIUSERS) { user in
                        VStack {
                            HStack {
                                Image(user.profileImageUrl[0])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size.dimension, height: size.dimension)
                                    .clipShape(Circle())

                                Text(user.fullname)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Spacer()
                            }
                            .onTapGesture {
                                dismiss()
                                chatVM.selectedUser = user
                                chatVM.showChat = true
                            }
                            
                            Divider()
                                .padding(.leading, 40)
                        }
                        .padding(.leading)
                    }
                }
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NewMessageView(chatVM: ChatViewModel())
}
